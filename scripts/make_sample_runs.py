"""Write clearly labelled SAMPLE run files so the results site has data before
the harness produces real runs. The models are fictional and the scores are
random numbers. Delete runs/sample-*.json once real runs exist.

    python scripts/make_sample_runs.py
"""

from __future__ import annotations

import json
import random
import subprocess
from pathlib import Path

from dataeng_bench.runs import RUNS_DIR, validate_run
from dataeng_bench.tasks import discover_tasks

DIFFICULTY_PENALTY = {"easy": 0.0, "medium": 0.12, "hard": 0.28}
TYPE_PENALTY = {"sql": 0.05, "structured": 0.0, "rubric": 0.08}

# (id, label, model, provider, strength, settings)
VARIANTS = {
    "aurora-xl-high": ("Aurora XL · high reasoning", "aurora-xl", "Sample Lab A", 0.93, {"reasoning_effort": "high"}),
    "aurora-xl-none": ("Aurora XL · no reasoning", "aurora-xl", "Sample Lab A", 0.80, {"reasoning_effort": "none"}),
    "aurora-mini": ("Aurora Mini", "aurora-mini", "Sample Lab A", 0.66, {"reasoning_effort": "medium"}),
    "basalt-pro": ("Basalt Pro", "basalt-pro", "Sample Lab B", 0.87, {"reasoning_effort": "medium"}),
    "basalt-pro-schema-hints": ("Basalt Pro · schema hints prompt", "basalt-pro", "Sample Lab B", 0.90, {"reasoning_effort": "medium", "system_prompt": "schema-hints-v1"}),
    "cirrus-70b": ("Cirrus 70B (open weights)", "cirrus-70b", "Sample Lab C", 0.62, {"temperature": 0.2}),
    "cirrus-8b": ("Cirrus 8B (open weights)", "cirrus-8b", "Sample Lab C", 0.38, {"temperature": 0.2}),
}

RUNS = [
    {
        "id": "sample-2026-11-10-first-look",
        "title": "First look: 4 models on data modeling",
        "description": "SAMPLE DATA. A first pass with one attempt per task.",
        "created_at": "2026-11-10T09:00:00Z",
        "published": True,
        "attempts": 1,
        "variants": ["aurora-xl-high", "aurora-mini", "basalt-pro", "cirrus-70b"],
        "seed": 1,
    },
    {
        "id": "sample-2026-11-18-reasoning-effort",
        "title": "Does reasoning effort matter for data modeling?",
        "description": "SAMPLE DATA. Same model with and without reasoning, plus a prompt variant with schema hints. Three attempts per task.",
        "created_at": "2026-11-18T14:30:00Z",
        "published": True,
        "attempts": 3,
        "variants": list(VARIANTS),
        "seed": 2,
    },
    {
        "id": "sample-2026-11-22-judge-check",
        "title": "Draft: rubric judge calibration",
        "description": "SAMPLE DATA. Unpublished run, only shown on preview builds.",
        "created_at": "2026-11-22T18:00:00Z",
        "published": False,
        "attempts": 1,
        "variants": ["aurora-xl-high", "basalt-pro"],
        "seed": 3,
    },
]


def main() -> None:
    tasks = discover_tasks()
    commit = subprocess.run(["git", "rev-parse", "--short", "HEAD"], capture_output=True, text=True).stdout.strip()
    for spec in RUNS:
        rng = random.Random(spec["seed"])
        variants, results = [], []
        for vid in spec["variants"]:
            label, model, provider, strength, settings = VARIANTS[vid]
            variants.append({"id": vid, "label": label, "model": model, "provider": provider, "settings": settings})
            for task in tasks:
                task_ease = rng.uniform(-0.1, 0.1)
                for attempt in range(1, spec["attempts"] + 1):
                    p = strength - DIFFICULTY_PENALTY[task.difficulty] - TYPE_PENALTY[task.answer_type] + task_ease
                    roll = rng.random()
                    if roll < p:
                        score = 1.0
                    elif roll < p + 0.25:
                        score = round(rng.uniform(0.3, 0.9), 3)
                    else:
                        score = round(rng.uniform(0.0, 0.3), 3)
                    out_tokens = int(rng.uniform(400, 2500) * (3 if settings.get("reasoning_effort") == "high" else 1))
                    results.append({
                        "variant": vid,
                        "task_id": task.id,
                        "attempt": attempt,
                        "score": score,
                        "passed": score == 1.0,
                        "error": None,
                        "input_tokens": int(rng.uniform(900, 2400)),
                        "output_tokens": out_tokens,
                        "cost_usd": round(out_tokens * strength * 0.00002, 5),
                        "duration_s": round(out_tokens / rng.uniform(40, 120), 1),
                    })
        run = {
            "schema_version": 1,
            "id": spec["id"],
            "title": spec["title"],
            "description": spec["description"],
            "created_at": spec["created_at"],
            "published": spec["published"],
            "sample": True,
            "benchmark": {"version": "0.1.0", "commit": commit, "task_ids": [t.id for t in tasks]},
            "settings": {"attempts_per_task": spec["attempts"], "judge_model": "aurora-xl"},
            "variants": variants,
            "results": results,
        }
        errors = validate_run(run, [t.id for t in tasks])
        assert not errors, errors
        path = RUNS_DIR / f"{spec['id']}.json"
        path.write_text(json.dumps(run, indent=1) + "\n")
        print(f"wrote {path.relative_to(RUNS_DIR.parent)}")


if __name__ == "__main__":
    main()
