"""Grade structured (JSON) answers against an answer key.

``answer_key.yaml`` lists fields by dotted path. Match modes:

``exact``         normalized string equality (case, spaces and hyphens ignored).
``one_of``        the answer equals any of ``expected`` (normalized).
``set``           the answer is a list whose normalized items equal ``expected``
                  as a set.
``set_of_sets``   a list of lists compared as a set of sets, for answers such as
                  candidate keys where neither order matters.
"""

from __future__ import annotations

import json
import re
from typing import Any

from ..tasks import Task
from .result import CheckResult, GradeResult


def extract_json(text: str) -> Any:
    """Parse JSON from a model reply, tolerating a surrounding code fence or prose."""
    text = text.strip()
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    fence = re.search(r"```(?:json)?\s*(.*?)```", text, re.DOTALL)
    if fence:
        try:
            return json.loads(fence.group(1))
        except json.JSONDecodeError:
            pass
    start, end = text.find("{"), text.rfind("}")
    if start != -1 and end > start:
        return json.loads(text[start : end + 1])
    raise ValueError("no JSON object found in answer")


def norm(value: Any) -> str:
    return re.sub(r"[\s\-]+", "_", str(value).strip().lower())


def lookup(data: Any, path: str) -> Any:
    for part in path.split("."):
        if not isinstance(data, dict) or part not in data:
            raise KeyError(path)
        data = data[part]
    return data


def _match(mode: str, answer: Any, expected: Any) -> bool:
    if mode == "exact":
        return norm(answer) == norm(expected)
    if mode == "one_of":
        return norm(answer) in {norm(e) for e in expected}
    if mode == "set":
        return isinstance(answer, list) and {norm(a) for a in answer} == {
            norm(e) for e in expected
        }
    if mode == "set_of_sets":
        if not isinstance(answer, list) or not all(isinstance(a, list) for a in answer):
            return False
        as_sets = {frozenset(norm(x) for x in a) for a in answer}
        return as_sets == {frozenset(norm(x) for x in e) for e in expected}
    raise ValueError(f"unknown match mode {mode!r}")


def grade_structured(task: Task, answer_text: str) -> GradeResult:
    result = GradeResult(task_id=task.id)
    key = task.load_yaml("answer_key.yaml")
    try:
        answer = extract_json(answer_text)
    except (ValueError, json.JSONDecodeError) as exc:
        result.error = f"could not parse JSON answer: {exc}"
        return result
    for field in key["fields"]:
        path = field["path"]
        weight = float(field.get("weight", 1))
        mode = field.get("match", "exact")
        try:
            given = lookup(answer, path)
        except KeyError:
            result.checks.append(CheckResult(path, False, weight, "missing from answer"))
            continue
        ok = _match(mode, given, field["expected"])
        msg = "" if ok else f"got {given!r}"
        result.checks.append(CheckResult(path, ok, weight, msg))
    return result
