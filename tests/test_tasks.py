"""Every task must be well formed, its reference answer must score 1.0 and its
known-wrong answers must not pass."""

from __future__ import annotations

import json

import pytest

from dataeng_bench.grading.grade import grade
from dataeng_bench.grading.rubric import build_judge_prompt, grade_rubric
from dataeng_bench.tasks import discover_tasks

TASKS = discover_tasks()
AUTO_GRADED = [t for t in TASKS if t.answer_type != "rubric"]
RUBRIC = [t for t in TASKS if t.answer_type == "rubric"]
NEGATIVES = [(t, p) for t in AUTO_GRADED for p in t.negative_paths]

REQUIRED_FILES = {
    "sql": ["prompt.md", "fixtures/setup.sql", "checks.yaml", "reference/solution.sql"],
    "structured": ["prompt.md", "answer_key.yaml", "reference/answer.json"],
    "rubric": ["prompt.md", "rubric.yaml", "reference/answer.md"],
}


def test_tasks_discovered():
    assert len(TASKS) >= 10
    assert len({t.id for t in TASKS}) == len(TASKS), "task ids must be unique"


@pytest.mark.parametrize("task", TASKS, ids=lambda t: t.id)
def test_task_is_well_formed(task):
    for rel in REQUIRED_FILES[task.answer_type]:
        assert task.file(rel).is_file(), f"missing {rel}"
    assert task.sources, "every task cites at least one source"
    for source in task.sources:
        assert source.get("title"), "every source needs a title"
    assert task.id.startswith(f"{task.category}.{task.subcategory}.")


@pytest.mark.parametrize("task", AUTO_GRADED, ids=lambda t: t.id)
def test_reference_answer_scores_full_marks(task):
    result = grade(task, task.reference_path.read_text())
    assert result.passed, result.summary()
    assert result.score == 1.0


@pytest.mark.parametrize(
    "task,negative", NEGATIVES, ids=lambda x: getattr(x, "id", getattr(x, "name", str(x)))
)
def test_negative_answer_does_not_pass(task, negative):
    result = grade(task, negative.read_text())
    assert not result.passed, f"{negative.name} should not pass:\n{result.summary()}"


@pytest.mark.parametrize("task", RUBRIC, ids=lambda t: t.id)
def test_rubric_judge_round_trip(task):
    rubric = task.load_yaml("rubric.yaml")
    prompt = build_judge_prompt(task, "my answer")
    for criterion in rubric["criteria"]:
        assert criterion["id"] in prompt
    full = {"criteria": [{"id": c["id"], "score": c["points"], "justification": "ok"} for c in rubric["criteria"]]}
    assert grade_rubric(task, json.dumps(full)).score == 1.0
    half = {"criteria": [{"id": c["id"], "score": 0} for c in rubric["criteria"][: len(rubric["criteria"]) // 2]]}
    result = grade_rubric(task, "```json\n" + json.dumps(half) + "\n```")
    assert result.score == 0.0 and not result.passed
