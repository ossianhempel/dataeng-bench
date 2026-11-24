"""Run results: the file the harness writes after running models on tasks.

One JSON file per run in ``runs/<run_id>.json``. The results site reads these
files at build time. See docs/results-format.md for the full format.
"""

from __future__ import annotations

import json
import re
from collections.abc import Iterable
from pathlib import Path
from typing import Any

from .tasks import REPO_ROOT

RUNS_DIR = REPO_ROOT / "runs"
SCHEMA_VERSION = 1
ID_RE = re.compile(r"^[a-z0-9][a-z0-9._-]*$")


def _require(cond: bool, errors: list[str], msg: str) -> None:
    if not cond:
        errors.append(msg)


def _is_num(v: Any) -> bool:
    return isinstance(v, (int, float)) and not isinstance(v, bool)


def validate_run(run: dict, known_task_ids: Iterable[str] | None = None) -> list[str]:
    """Return a list of problems with a run file. Empty means valid."""
    errors: list[str] = []
    req = lambda c, m: _require(c, errors, m)  # noqa: E731

    req(run.get("schema_version") == SCHEMA_VERSION, f"schema_version must be {SCHEMA_VERSION}")
    run_id = run.get("id")
    req(isinstance(run_id, str) and bool(ID_RE.match(run_id or "")), "id must be a lowercase slug")
    req(isinstance(run.get("title"), str) and run["title"].strip() != "", "title is required")
    req(isinstance(run.get("created_at"), str), "created_at must be an ISO 8601 string")
    req(isinstance(run.get("published"), bool), "published must be true or false")
    req(isinstance(run.get("sample", False), bool), "sample must be true or false")

    bench = run.get("benchmark") or {}
    task_ids = bench.get("task_ids")
    req(isinstance(task_ids, list) and len(task_ids) > 0, "benchmark.task_ids must list the tasks run")
    task_ids = task_ids if isinstance(task_ids, list) else []
    req(len(set(task_ids)) == len(task_ids), "benchmark.task_ids has duplicates")
    if known_task_ids is not None:
        known = set(known_task_ids)
        for t in task_ids:
            req(t in known, f"benchmark.task_ids: unknown task {t!r}")

    variants = run.get("variants")
    req(isinstance(variants, list) and len(variants) > 0, "variants must be a non-empty list")
    variant_ids: set[str] = set()
    for i, v in enumerate(variants or []):
        vid = v.get("id")
        req(isinstance(vid, str) and bool(ID_RE.match(vid or "")), f"variants[{i}].id must be a slug")
        req(vid not in variant_ids, f"variants[{i}].id {vid!r} is duplicated")
        variant_ids.add(vid)
        for key in ("label", "model", "provider"):
            req(isinstance(v.get(key), str) and v[key] != "", f"variants[{i}].{key} is required")
        req(isinstance(v.get("settings", {}), dict), f"variants[{i}].settings must be an object")

    results = run.get("results")
    req(isinstance(results, list), "results must be a list")
    seen: set[tuple] = set()
    for i, r in enumerate(results or []):
        where = f"results[{i}]"
        req(r.get("variant") in variant_ids, f"{where}.variant {r.get('variant')!r} is not a variant id")
        req(r.get("task_id") in task_ids, f"{where}.task_id {r.get('task_id')!r} is not in benchmark.task_ids")
        attempt = r.get("attempt", 1)
        req(isinstance(attempt, int) and attempt >= 1, f"{where}.attempt must be an integer >= 1")
        key = (r.get("variant"), r.get("task_id"), attempt)
        req(key not in seen, f"{where} duplicates variant/task/attempt {key}")
        seen.add(key)
        score = r.get("score")
        req(_is_num(score) and 0 <= score <= 1, f"{where}.score must be a number from 0 to 1")
        req(isinstance(r.get("passed"), bool), f"{where}.passed must be true or false")
        for k in ("input_tokens", "output_tokens", "cost_usd", "duration_s"):
            if r.get(k) is not None:
                req(_is_num(r[k]) and r[k] >= 0, f"{where}.{k} must be a non-negative number")
    return errors


def load_runs(root: str | Path = RUNS_DIR) -> list[dict]:
    """All run files, newest first."""
    runs = [json.loads(p.read_text()) for p in sorted(Path(root).glob("*.json"))]
    return sorted(runs, key=lambda r: r.get("created_at", ""), reverse=True)
