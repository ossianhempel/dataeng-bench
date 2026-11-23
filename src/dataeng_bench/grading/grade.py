from __future__ import annotations

from ..tasks import Task
from .result import GradeResult
from .rubric import grade_rubric
from .sql import grade_sql
from .structured import grade_structured


def grade(task: Task, answer: str, judge_reply: str | None = None) -> GradeResult:
    """Grade one answer. Rubric tasks need the judge model's reply."""
    if task.answer_type == "sql":
        return grade_sql(task, answer)
    if task.answer_type == "structured":
        return grade_structured(task, answer)
    if judge_reply is None:
        raise ValueError(f"{task.id} is rubric-graded: pass the judge model's reply")
    return grade_rubric(task, judge_reply)
