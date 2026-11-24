"""Grade SQL answers by running them against a DuckDB fixture.

Flow for one task:

1. Create an in-memory DuckDB database and run ``fixtures/setup.sql``.
2. Fingerprint every table the fixture created (the "source tables").
3. Run the candidate SQL script with a timeout, with file and network access
   disabled.
4. Fail the task outright if a source table was dropped or changed.
5. Run the optional ``seed`` SQL from ``checks.yaml``. Seed rows are valid
   under the task's rules, so a schema that rejects them scores zero.
6. Run each check from ``checks.yaml`` (each under the same timeout, since
   checks evaluate the answer's views) and weight the results.

Check types (see docs/grading.md for examples):

``assert``          SQL that returns a single TRUE value.
``rows``            SQL whose result must equal ``expected`` (unordered unless
                    ``ordered: true``; numbers compared after rounding).
``columns``         ``table`` must exist and contain every name in ``columns``.
``accepts``         SQL that must run without error (inside a rolled-back
                    transaction, so checks stay independent). An optional
                    ``assert_sql`` then runs in the same transaction and must
                    return TRUE, to test defaults and derived values.
``rejects``         SQL that must fail with a constraint or conversion error,
                    inside a rolled-back transaction. A missing table or column
                    does not count as a rejection.
``fd_normalized``   For each functional dependency X -> Y, every base table the
                    candidate created that holds X and some of Y must have X
                    unique. This catches redundancy without fixing the table
                    names the candidate has to use.
"""

from __future__ import annotations

import datetime as dt
import decimal
import json
import threading
from collections.abc import Iterator
from contextlib import contextmanager
from typing import Any

import duckdb

from ..tasks import Task
from .result import CheckResult, GradeResult

ROUND_DIGITS = 4
MAX_DIFF_ROWS = 5


def _connect() -> duckdb.DuckDBPyConnection:
    # Answers are untrusted model output. Block file and network access
    # (COPY TO, read_csv, ATTACH, httpfs ...) and extension installs, then lock
    # the configuration so the answer cannot turn them back on.
    conn = duckdb.connect(
        ":memory:",
        config={
            "enable_external_access": False,
            "autoinstall_known_extensions": False,
            "autoload_known_extensions": False,
        },
    )
    conn.execute("SET lock_configuration = true")
    return conn


def _table_names(conn: duckdb.DuckDBPyConnection, base_only: bool = False) -> list[str]:
    sql = (
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_schema = 'main'"
    )
    if base_only:
        sql += " AND table_type = 'BASE TABLE'"
    return sorted(r[0] for r in conn.execute(sql).fetchall())


def _fingerprint(conn: duckdb.DuckDBPyConnection, tables: list[str]) -> dict[str, Any]:
    prints = {}
    for name in tables:
        prints[name] = conn.execute(
            f'SELECT count(*), bit_xor(hash(t)) FROM "{name}" AS t'
        ).fetchone()
    return prints


@contextmanager
def _deadline(conn: duckdb.DuckDBPyConnection, seconds: float) -> Iterator[None]:
    """Interrupt whatever the connection is running once ``seconds`` pass.

    Used for the answer script and for every check, because a check can
    evaluate a view the answer defined and that view can be arbitrarily slow.
    """
    timer = threading.Timer(seconds, conn.interrupt)
    timer.start()
    try:
        yield
    finally:
        timer.cancel()


def normalize_value(value: Any) -> Any:
    if value is None or isinstance(value, bool):
        return value
    if isinstance(value, (int, float, decimal.Decimal)):
        return round(float(value), ROUND_DIGITS) + 0.0  # +0.0 turns -0.0 into 0.0
    if isinstance(value, dt.datetime):
        return value.replace(tzinfo=None).isoformat(sep=" ")
    if isinstance(value, (dt.date, dt.time)):
        return value.isoformat()
    if isinstance(value, str):
        return value
    return str(value)


def normalize_rows(rows: list[Any]) -> list[tuple]:
    out = []
    for row in rows:
        if not isinstance(row, (list, tuple)):
            row = [row]
        out.append(tuple(normalize_value(v) for v in row))
    return out


def _sort_key(row: tuple) -> str:
    return json.dumps(row, default=str)


def _compare_rows(actual: list[tuple], expected: list[tuple], ordered: bool) -> str | None:
    if not ordered:
        actual = sorted(actual, key=_sort_key)
        expected = sorted(expected, key=_sort_key)
    if actual == expected:
        return None
    if ordered and sorted(actual, key=_sort_key) == sorted(expected, key=_sort_key):
        return "rows match but the order is wrong"
    missing = [r for r in expected if r not in actual]
    unexpected = [r for r in actual if r not in expected]
    parts = [f"expected {len(expected)} rows, got {len(actual)}"]
    if missing:
        parts.append(f"missing {missing[:MAX_DIFF_ROWS]}")
    if unexpected:
        parts.append(f"unexpected {unexpected[:MAX_DIFF_ROWS]}")
    return "; ".join(parts)


def _in_rolled_back_txn(
    conn: duckdb.DuckDBPyConnection, sql: str, assert_sql: str | None = None
) -> Exception | str | None:
    """Run SQL in a transaction that is always rolled back.

    Returns the error raised by ``sql``, a message if ``assert_sql`` is not
    TRUE, or None on success.
    """
    conn.execute("BEGIN TRANSACTION")
    try:
        try:
            conn.execute(sql)
        except duckdb.Error as exc:
            return exc
        if assert_sql:
            rows = conn.execute(assert_sql).fetchall()
            if not (len(rows) == 1 and rows[0][0] is True):
                return f"follow-up assertion returned {rows[:3]}"
        return None
    finally:
        conn.execute("ROLLBACK")


REJECT_ERRORS = {
    "constraint": duckdb.ConstraintException,
    "conversion": duckdb.ConversionException,
}


def _table_columns(conn: duckdb.DuckDBPyConnection, table: str) -> list[str]:
    rows = conn.execute(
        "SELECT column_name FROM information_schema.columns "
        "WHERE table_schema = 'main' AND lower(table_name) = lower(?) "
        "ORDER BY ordinal_position",
        [table],
    ).fetchall()
    return [r[0] for r in rows]


def _check_fd_normalized(
    conn: duckdb.DuckDBPyConnection, check: dict, candidate_tables: list[str]
) -> tuple[bool, str]:
    problems = []
    for fd in check["fds"]:
        determinant = [c.lower() for c in fd["determinant"]]
        dependent = [c.lower() for c in fd["dependent"]]
        for table in candidate_tables:
            cols = {c.lower(): c for c in _table_columns(conn, table)}
            if not all(c in cols for c in determinant):
                continue
            held = [c for c in dependent if c in cols]
            if not held:
                continue
            key = ", ".join(f'"{cols[c]}"' for c in determinant)
            dupes = conn.execute(
                f'SELECT count(*) FROM (SELECT {key} FROM "{table}" '
                f"GROUP BY {key} HAVING count(*) > 1)"
            ).fetchone()[0]
            if dupes:
                problems.append(
                    f"{table}: {', '.join(determinant)} -> {', '.join(held)} "
                    f"is stored redundantly ({dupes} repeated determinant values)"
                )
    return (not problems, "; ".join(problems))


def run_check(
    conn: duckdb.DuckDBPyConnection, check: dict, candidate_tables: list[str]
) -> CheckResult:
    name = check["name"]
    weight = float(check.get("weight", 1))
    kind = check["type"]
    try:
        if kind == "assert":
            rows = conn.execute(check["sql"]).fetchall()
            ok = len(rows) == 1 and len(rows[0]) >= 1 and rows[0][0] is True
            msg = "" if ok else f"assertion returned {rows[:3]}"
            return CheckResult(name, ok, weight, msg)
        if kind == "rows":
            actual = normalize_rows(conn.execute(check["sql"]).fetchall())
            expected = normalize_rows(check["expected"])
            diff = _compare_rows(actual, expected, bool(check.get("ordered", False)))
            return CheckResult(name, diff is None, weight, diff or "")
        if kind == "columns":
            have = {c.lower() for c in _table_columns(conn, check["table"])}
            if not have:
                return CheckResult(name, False, weight, f"table {check['table']} not found")
            missing = [c for c in check["columns"] if c.lower() not in have]
            return CheckResult(
                name, not missing, weight, f"missing columns {missing}" if missing else ""
            )
        if kind == "accepts":
            outcome = _in_rolled_back_txn(conn, check["sql"], check.get("assert_sql"))
            if outcome is None:
                return CheckResult(name, True, weight)
            if isinstance(outcome, str):
                return CheckResult(name, False, weight, outcome)
            return CheckResult(name, False, weight, f"statement failed: {outcome}")
        if kind == "rejects":
            allowed = tuple(
                REJECT_ERRORS[e] for e in check.get("expect_error", ["constraint", "conversion"])
            )
            exc = _in_rolled_back_txn(conn, check["sql"])
            if exc is None:
                return CheckResult(name, False, weight, "statement was accepted but should fail")
            if isinstance(exc, allowed):
                return CheckResult(name, True, weight)
            return CheckResult(
                name, False, weight, f"failed for the wrong reason ({type(exc).__name__}: {exc})"
            )
        if kind == "fd_normalized":
            ok, msg = _check_fd_normalized(conn, check, candidate_tables)
            return CheckResult(name, ok, weight, msg)
        raise ValueError(f"unknown check type {kind!r}")
    except duckdb.Error as exc:
        return CheckResult(name, False, weight, f"{type(exc).__name__}: {exc}")


def grade_sql(task: Task, answer_sql: str) -> GradeResult:
    result = GradeResult(task_id=task.id)
    spec = task.load_yaml("checks.yaml")
    conn = _connect()
    try:
        conn.execute(task.read("fixtures/setup.sql"))
        sources = _table_names(conn)
        before = _fingerprint(conn, sources)

        if not answer_sql.strip():
            result.error = "empty answer"
            return result
        try:
            with _deadline(conn, task.timeout_seconds):
                conn.execute(answer_sql)
        except duckdb.Error as exc:
            result.error = f"answer SQL failed: {type(exc).__name__}: {exc}"
            return result

        now = set(_table_names(conn))
        gone = [t for t in sources if t not in now]
        if gone:
            result.error = f"answer dropped source tables: {gone}"
            return result
        after = _fingerprint(conn, sources)
        changed = [t for t in sources if before[t] != after[t]]
        if changed:
            result.error = f"answer modified source tables: {changed}"
            return result

        if spec.get("seed"):
            try:
                with _deadline(conn, task.timeout_seconds):
                    conn.execute(spec["seed"])
            except duckdb.Error as exc:
                result.error = f"valid seed data was rejected: {type(exc).__name__}: {exc}"
                return result

        candidate_base_tables = [t for t in _table_names(conn, base_only=True) if t not in sources]
        for check in spec["checks"]:
            with _deadline(conn, task.timeout_seconds):
                result.checks.append(run_check(conn, check, candidate_base_tables))
        return result
    finally:
        conn.close()
