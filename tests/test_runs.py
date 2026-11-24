"""Run result files must follow docs/results-format.md and name real tasks."""

from __future__ import annotations

import copy

import pytest

from dataeng_bench.runs import load_runs, validate_run
from dataeng_bench.tasks import discover_tasks

TASK_IDS = {t.id for t in discover_tasks()}
RUNS = load_runs()


@pytest.mark.parametrize("run", RUNS, ids=[r["id"] for r in RUNS])
def test_run_files_valid(run):
    assert validate_run(run, TASK_IDS) == []


def _minimal() -> dict:
    return {
        "schema_version": 1,
        "id": "r1",
        "title": "Run",
        "created_at": "2026-11-24T00:00:00Z",
        "published": False,
        "benchmark": {"task_ids": ["t1"]},
        "variants": [{"id": "v1", "label": "V1", "model": "m", "provider": "p"}],
        "results": [{"variant": "v1", "task_id": "t1", "score": 0.5, "passed": False}],
    }


def test_minimal_run_is_valid():
    assert validate_run(_minimal(), {"t1"}) == []


@pytest.mark.parametrize(
    "mutate, fragment",
    [
        (lambda r: r["results"][0].update(score=1.5), "score"),
        (lambda r: r["results"][0].update(variant="nope"), "not a variant id"),
        (lambda r: r["results"][0].update(task_id="t2"), "not in benchmark.task_ids"),
        (lambda r: r["results"].append(dict(r["results"][0])), "duplicates"),
        (lambda r: r.update(published="yes"), "published"),
        (lambda r: r["benchmark"].update(task_ids=["unknown"]), "unknown task"),
    ],
)
def test_invalid_runs_are_caught(mutate, fragment):
    run = copy.deepcopy(_minimal())
    mutate(run)
    assert any(fragment in e for e in validate_run(run, {"t1"}))
