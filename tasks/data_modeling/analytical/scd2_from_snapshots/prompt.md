# Build a Type 2 customer dimension from snapshots

The CRM can't send change events, so a job copies the full customer table into
DuckDB on some days (not every day):

```sql
CREATE TABLE raw_customer_snapshots (
    snapshot_date DATE,      -- the day the full copy was taken
    customer_id   VARCHAR,
    email         VARCHAR,
    tier          VARCHAR,   -- 'bronze', 'silver', 'gold'
    city          VARCHAR    -- can be NULL
);
```

Each snapshot holds every customer that existed on that day, one row each.

## Your task

Write a DuckDB SQL script that creates the table `dim_customer_scd2` with
columns `customer_id`, `email`, `tier`, `city`, `valid_from`, `valid_to`,
`is_current`, following these rules:

- `tier` and `city` are Type 2 attributes. A new version starts on the first
  snapshot where either value differs from the previous snapshot of that
  customer. A change from NULL to a value, or back, is a change.
- `email` is a Type 1 attribute: every version of a customer shows the email
  from that customer's most recent snapshot. An email change alone does not
  create a new version.
- A customer's first version starts on the first snapshot they appear in.
- Versions use half-open intervals: `valid_from` is inclusive and `valid_to`
  is exclusive and equals the next version's `valid_from`. Both are DATEs.
- A customer missing from the latest snapshot has been deleted. Close their last
  version with `valid_to` set to the date of the first snapshot that no longer
  contains them.
- The current version of a customer still present in the latest snapshot has
  `valid_to = NULL` and `is_current = TRUE`. Every other row has
  `is_current = FALSE`.

Do not modify the raw table. Return only the SQL script.
