# Run results format

A **run** is one execution of the benchmark: a set of tasks, run against one or
more **variants** (a model plus its settings, such as reasoning effort or a
different system prompt), possibly several attempts per task. The harness
writes each run to `runs/<run_id>.json`. The results site in `site/` reads that
folder at build time, so committing a run file is how a run gets published.

Check files with `dataeng-bench validate-runs`. CI runs it too.

## Example

```json
{
  "schema_version": 1,
  "id": "2026-12-01-frontier-models",
  "title": "Frontier models on data modeling",
  "description": "Optional. One or two sentences shown on the run page.",
  "created_at": "2026-12-01T09:00:00Z",
  "published": true,
  "sample": false,
  "benchmark": {
    "version": "0.1.0",
    "commit": "a692849",
    "task_ids": ["data_modeling.analytical.scd2_from_snapshots", "..."]
  },
  "settings": { "attempts_per_task": 3, "judge_model": "..." },
  "variants": [
    {
      "id": "model-x-high",
      "label": "Model X · high reasoning",
      "model": "model-x-2026-11",
      "provider": "Lab",
      "settings": { "reasoning_effort": "high", "temperature": 0 }
    }
  ],
  "results": [
    {
      "variant": "model-x-high",
      "task_id": "data_modeling.analytical.scd2_from_snapshots",
      "attempt": 1,
      "score": 0.833,
      "passed": false,
      "error": null,
      "checks": [{ "name": "...", "passed": true, "weight": 1.0, "message": "" }],
      "input_tokens": 1830,
      "output_tokens": 2410,
      "cost_usd": 0.041,
      "duration_s": 22.4
    }
  ]
}
```

## Fields

| Field | Required | Meaning |
|---|---|---|
| `schema_version` | yes | Always `1` for now. |
| `id` | yes | Lowercase slug, unique across runs. Use it as the file name. |
| `title` | yes | Short name shown in lists and as the chart title. |
| `description` | no | Shown on the run page. |
| `created_at` | yes | ISO 8601 timestamp. The newest published run is the home page chart. |
| `published` | yes | `false` keeps the run off the public site. Drafts still show in local and preview builds. |
| `sample` | no | `true` marks made-up data. The site labels it everywhere. |
| `benchmark.task_ids` | yes | Every task the run covered, including ones a variant failed or skipped. |
| `benchmark.version`, `benchmark.commit` | no | Which version of the tasks was run. |
| `settings` | no | Run-wide settings, free form. |
| `variants[]` | yes | `id` (slug), `label` (display name), `model` (exact API model id), `provider`, and free-form `settings`. |
| `results[]` | yes | One row per variant, task and attempt. |
| `results[].score` | yes | 0 to 1, the `score` from `GradeResult.to_dict()`. |
| `results[].passed` | yes | The `passed` from `GradeResult.to_dict()`. |
| `results[].attempt` | no | Starts at 1. Defaults to 1. |
| `results[].checks`, `error` | no | Copied from `GradeResult.to_dict()`. |
| `input_tokens`, `output_tokens`, `cost_usd`, `duration_s` | no | Usage, when known. |

A task with no result row for a variant counts as a score of 0 for that variant,
so a crash or timeout never improves an average. Write the row with
`"score": 0, "passed": false, "error": "..."` when you can.

## How the site scores a run

- **Task score** for a variant: the mean `score` over its attempts.
- **Overall score**: the mean task score over `benchmark.task_ids`, shown as 0 to 100.
- **Pass rate**: the share of attempts with `passed: true`.

Every task counts the same, whatever its difficulty or number of checks.

## Sample runs

`runs/sample-*.json` are made-up runs for fictional models, written by
`scripts/make_sample_runs.py` so the site has something to show before the
harness exists. Delete them when real runs land.
