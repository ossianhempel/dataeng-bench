# Task format

Each task is a directory under `tasks/<category>/<subcategory>/<task_name>/`.

```
task.yaml              metadata: id, title, difficulty, answer_type, tags, sources
prompt.md              exactly what the model is shown
fixtures/setup.sql     (sql) DuckDB script that creates and fills the source tables
checks.yaml            (sql) checks run against the database after the answer
answer_key.yaml        (structured) expected values per JSON field
rubric.yaml            (rubric) criteria and points for the LLM judge
reference/             a known-good answer: solution.sql, answer.json or answer.md
negative/              optional known-wrong answers (common mistakes) that must not pass
```

## task.yaml

```yaml
id: data_modeling.analytical.scd2_from_snapshots   # <category>.<subcategory>.<name>
title: Build a Type 2 slowly changing dimension from daily snapshots
category: data_modeling
subcategory: analytical        # transactional | analytical
difficulty: medium             # easy | medium | hard
answer_type: sql               # sql | structured | rubric
tags: [scd, scd-type-2]
timeout_seconds: 30            # optional, sql only
sources:                       # where the idea and the expected answer come from
  - title: "Kimball Group: Type 2 (add new row)"
    url: https://www.kimballgroup.com/...
    note: what this source informed
```

## Answer types

| Type | The model returns | Graded by |
|---|---|---|
| `sql` | A DuckDB SQL script that creates the tables or views named in the prompt | Running it against the fixture and executing `checks.yaml` |
| `structured` | A JSON object in the shape the prompt shows | Field-by-field comparison with `answer_key.yaml` |
| `rubric` | Free text (a design, a review) | An LLM judge scoring each criterion in `rubric.yaml`, with the reference answer as guidance |

Prefer `sql`, then `structured`. Use `rubric` only for open design questions
where there is no single right answer.

## Writing a good task

- State the output contract exactly: table names, column names, types where it
  matters, and how edge cases should be handled. The model should never have to
  guess a naming convention to score.
- Put the interesting edge cases in the fixture (duplicates, late-arriving
  keys, boundary dates, NULLs, reverted changes), but do not show the full
  fixture in the prompt. Show the schema and a few sample rows at most.
- Add at least one `negative/` answer that encodes the most common mistake, so
  the checks are proven to catch it.
- Cite sources for the concept and for the expected answer. Write prompts and
  references in your own words; do not copy text from books or articles.
- Run `dataeng-bench validate <task-dir>` and `pytest` before opening a PR.
