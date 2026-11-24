# dataeng-bench

An open benchmark for evaluating LLMs on real-world data and analytics engineering work.

## Goal

Most LLM benchmarks test general coding or trivia. dataeng-bench focuses on the work data and analytics engineers actually do, such as writing and debugging SQL, building and fixing dbt models, data modeling, pipeline and orchestration tasks, data quality checks, and answering business questions from a warehouse.

The aim is to:

- Provide a representative, reproducible set of tasks with automatic grading.
- Run the same tasks across different LLMs and agents to compare them fairly.
- Publish results with clear visualizations that anyone can read, not just ML researchers.

## Status

The first category, **data modeling**, has 19 tasks covering transactional
(OLTP) and analytical (OLAP) modeling. See [tasks/data_modeling](tasks/data_modeling/README.md).
The model-running harness and the results site are next.

## Quick start

```bash
pip install -e '.[dev]'
dataeng-bench list                                   # all tasks
dataeng-bench show tasks/data_modeling/analytical/scd2_from_snapshots
dataeng-bench grade tasks/data_modeling/analytical/scd2_from_snapshots my_answer.sql
dataeng-bench validate                               # reference answers pass, known mistakes fail
pytest
```

SQL tasks run against [DuckDB](https://duckdb.org), so every task is
reproducible locally with no warehouse account. See [docs/task-format.md](docs/task-format.md)
and [docs/grading.md](docs/grading.md).

## License

Apache-2.0. See [LICENSE](LICENSE).
