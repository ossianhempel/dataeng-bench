# Grading

Every graded answer gets a `score` from 0 to 1 (the weighted share of checks
passed) and a `passed` flag (every check passed). Leaderboards should report
both: `passed` is the strict pass rate, `score` shows partial progress.

## SQL tasks

1. A fresh in-memory DuckDB database runs `fixtures/setup.sql`.
2. The grader fingerprints every source table.
3. The answer script runs, with a timeout.
4. If the answer fails, drops a source table or changes its rows, the score is 0.
5. The optional `seed` from `checks.yaml` runs. Seed rows are valid under the
   task's rules, so a schema that rejects them scores 0.
6. Each check runs and contributes its `weight`.

Check types:

```yaml
checks:
  - name: one_row_per_order_line          # SQL returning a single TRUE
    type: assert
    sql: SELECT count(*) = count(DISTINCT (order_id, line_number)) FROM fct_order_lines

  - name: revenue_by_category              # result must equal expected rows
    type: rows                             # unordered unless ordered: true
    weight: 2                              # numbers compared after rounding to 4 decimals
    sql: SELECT category, sum(net_amount) FROM ... GROUP BY 1
    expected: [[Kitchen, 90.00], [Home, 90.00]]

  - name: has_columns                      # table exists with these columns
    type: columns
    table: fct_order_lines
    columns: [order_id, line_number]

  - name: order_status_defaults_to_pending # must succeed (in a rolled-back transaction)
    type: accepts
    sql: INSERT INTO orders (order_id, customer_id, ordered_at) VALUES (102, 1, now())
    assert_sql: SELECT status = 'pending' FROM orders WHERE order_id = 102

  - name: rejects_unknown_customer         # must fail with a constraint or conversion error;
    type: rejects                          # a missing table or column does not count
    sql: INSERT INTO orders (...) VALUES (110, 999, ...)

  - name: no_redundant_dependencies        # for each FD X -> Y, any table the answer created
    type: fd_normalized                    # that holds X and part of Y must have X unique
    fds:
      - {determinant: [course_code], dependent: [course_title, dept_code]}
```

`accepts`/`rejects` let a task grade DDL (keys, constraints, defaults) by
behaviour instead of by comparing text. `fd_normalized` grades a normalization
without forcing a particular set of table names.

## Structured tasks

The grader pulls the first JSON object out of the reply (a code fence or
surrounding prose is fine) and compares fields listed in `answer_key.yaml`.
Strings are compared case-insensitively, with spaces and hyphens treated as
underscores. Match modes: `exact`, `one_of`, `set`, `set_of_sets`.

## Rubric tasks

`dataeng-bench judge-prompt <task> <answer>` builds the judge prompt: the task,
the reference answer, the rubric and the candidate answer. The harness sends it
to a judge model and passes the reply to `dataeng-bench grade <task> <answer>
--judge-reply <file>`. Each criterion earns 0 to its points.

Judge choices affect results, so a leaderboard should:

- use one fixed judge model for all candidates and publish which one,
- not let a model judge its own answers where avoidable (or report it),
- report rubric tasks separately from auto-graded tasks.

## Validating tasks

`dataeng-bench validate` grades every reference answer (must score 1.0) and
every `negative/` answer (must not pass). `pytest` runs the same checks plus
grader unit tests.
