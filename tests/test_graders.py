from __future__ import annotations

import pytest

from dataeng_bench.grading.grade import grade
from dataeng_bench.grading.sql import normalize_rows
from dataeng_bench.grading.structured import extract_json
from dataeng_bench.tasks import TASKS_DIR, load_task

FAN_TRAP = TASKS_DIR / "data_modeling/analytical/fan_trap_customer_summary"
NORMAL_FORMS = TASKS_DIR / "data_modeling/transactional/identify_normal_forms"


def test_empty_answer_scores_zero():
    result = grade(load_task(FAN_TRAP), "   ")
    assert result.score == 0 and result.error


def test_broken_sql_scores_zero():
    result = grade(load_task(FAN_TRAP), "CREATE TABLE rpt_customer_summary AS SELEC 1")
    assert result.score == 0 and "failed" in result.error


def test_modifying_a_source_table_scores_zero():
    task = load_task(FAN_TRAP)
    answer = "DELETE FROM payments WHERE payment_id = 1;\n" + task.reference_path.read_text()
    result = grade(task, answer)
    assert result.score == 0 and "modified source tables" in result.error


def test_dropping_a_source_table_scores_zero():
    task = load_task(FAN_TRAP)
    answer = task.reference_path.read_text() + "\nDROP TABLE payments;"
    result = grade(task, answer)
    assert result.score == 0 and "dropped" in result.error


def test_partial_credit_for_partial_sql():
    task = load_task(FAN_TRAP)
    answer = """
    CREATE TABLE rpt_customer_summary AS
    SELECT c.customer_id, count(o.order_id) AS order_count, 0 AS items_ordered,
           coalesce(sum(o.order_amount), 0) AS order_value, 0 AS amount_paid
    FROM customers c LEFT JOIN orders o USING (customer_id) GROUP BY 1;
    """
    result = grade(task, answer)
    assert 0 < result.score < 1 and not result.passed


def test_normalize_rows_handles_numbers_dates_and_scalars():
    import datetime as dt
    import decimal

    assert normalize_rows([(decimal.Decimal("1.50"), dt.date(2024, 1, 2), None)]) == [
        (1.5, "2024-01-02", None)
    ]
    assert normalize_rows([5]) == [(5.0,)]


@pytest.mark.parametrize(
    "text",
    [
        '{"a": 1}',
        'Here you go:\n```json\n{"a": 1}\n```',
        'The answer is {"a": 1} as requested.',
    ],
)
def test_extract_json_tolerates_wrapping(text):
    assert extract_json(text) == {"a": 1}


def test_structured_partial_credit_and_normalization():
    task = load_task(NORMAL_FORMS)
    answer = """{"q1": {"candidate_keys": [["product_id", "order_id"]],
                        "highest_normal_form": "1nf", "violating_determinant": ["Product_ID"]}}"""
    result = grade(task, answer)
    by_name = {c.name: c for c in result.checks}
    assert by_name["q1.highest_normal_form"].passed
    assert by_name["q1.candidate_keys"].passed
    assert by_name["q1.violating_determinant"].passed
    assert not by_name["q2.highest_normal_form"].passed
    assert 0 < result.score < 1


def test_unparseable_structured_answer():
    result = grade(load_task(NORMAL_FORMS), "I think q1 is in 2NF")
    assert result.score == 0 and result.error


NORMALIZE = TASKS_DIR / "data_modeling/transactional/normalize_enrollments_3nf"


@pytest.mark.parametrize(
    "statement",
    [
        "COPY (SELECT 1) TO '/tmp/dataeng_bench_escape.csv'",
        "CREATE TABLE leak AS SELECT * FROM read_csv('/etc/passwd')",
        "SET enable_external_access = true",
    ],
)
def test_answers_cannot_touch_the_filesystem(statement, tmp_path):
    task = load_task(FAN_TRAP)
    result = grade(task, statement + ";\n" + task.reference_path.read_text())
    assert result.score == 0 and "failed" in result.error


def test_slow_view_is_interrupted_during_checks():
    task = load_task(NORMALIZE)
    task.timeout_seconds = 1
    # Creating the view is instant; evaluating it never ends.
    answer = """
    CREATE VIEW enrollments_flat AS
    WITH RECURSIVE r(n) AS (SELECT 1 UNION ALL SELECT n + 1 FROM r)
    SELECT e.* FROM raw_enrollments e, r;
    """
    import time

    start = time.monotonic()
    result = grade(task, answer)
    assert time.monotonic() - start < 15
    assert not result.passed
    assert any("Interrupt" in c.message for c in result.checks)
