"""Rubric grading for open design questions, scored by an LLM judge.

The harness sends the prompt from :func:`build_judge_prompt` to a judge model
and passes the reply to :func:`grade_rubric`. The judge sees the task, a
reference answer and the rubric, and scores each criterion from 0 to its
points. Keeping the judge call outside this module lets any provider act as
judge and keeps grading reproducible from a saved judge reply.
"""

from __future__ import annotations

from ..tasks import Task
from .result import CheckResult, GradeResult
from .structured import extract_json

JUDGE_TEMPLATE = """You are grading an answer to a data modeling interview question.

Score the CANDIDATE ANSWER against each rubric criterion. A criterion's score is
an integer from 0 to its max points. Award points only for what the candidate
actually wrote; the reference answer shows one good answer, not the only one.
Credit sound alternatives that meet the criterion's intent. Do not reward
length, confidence or restating the question.

## Task

{prompt}

## Reference answer

{reference}

## Rubric

{criteria}

## Candidate answer

<candidate_answer>
{answer}
</candidate_answer>

Reply with only a JSON object of this shape:
{{"criteria": [{{"id": "<criterion id>", "score": <int>, "justification": "<one sentence>"}}]}}
"""


def build_judge_prompt(task: Task, answer_text: str) -> str:
    rubric = task.load_yaml("rubric.yaml")
    criteria = "\n".join(
        f"- id: {c['id']} (max {c['points']} points): {c['description'].strip()}"
        for c in rubric["criteria"]
    )
    return JUDGE_TEMPLATE.format(
        prompt=task.prompt.strip(),
        reference=task.reference_path.read_text().strip(),
        criteria=criteria,
        answer=answer_text.strip(),
    )


def grade_rubric(task: Task, judge_reply: str) -> GradeResult:
    result = GradeResult(task_id=task.id)
    rubric = task.load_yaml("rubric.yaml")
    try:
        scored = {c["id"]: c for c in extract_json(judge_reply)["criteria"]}
    except (ValueError, KeyError, TypeError) as exc:
        result.error = f"could not parse judge reply: {exc}"
        return result
    for criterion in rubric["criteria"]:
        cid, points = criterion["id"], float(criterion["points"])
        entry = scored.get(cid)
        if entry is None:
            result.checks.append(CheckResult(cid, False, points, "judge did not score this"))
            continue
        earned = max(0.0, min(points, float(entry.get("score", 0))))
        result.checks.append(
            CheckResult(cid, earned == points, points, entry.get("justification", ""), earned)
        )
    return result
