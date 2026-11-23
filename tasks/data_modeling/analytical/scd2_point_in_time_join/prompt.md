# Point-in-time join to a Type 2 dimension

DuckDB holds a Type 2 customer dimension and raw orders:

```sql
CREATE TABLE dim_customer (
    customer_sk INTEGER,   -- surrogate key; -1 is the unknown member
    customer_id VARCHAR,   -- natural key
    tier        VARCHAR,
    valid_from  DATE,      -- inclusive
    valid_to    DATE,      -- exclusive; NULL for the current version
    is_current  BOOLEAN
);

CREATE TABLE raw_orders (
    order_id    INTEGER,
    customer_id VARCHAR,
    order_date  DATE,
    amount      DECIMAL(10, 2)
);
```

The unknown member row is `(-1, 'UNKNOWN', 'Unknown', NULL, NULL, TRUE)`.
Real versions of a customer never overlap.

## Your task

Write a DuckDB SQL script that creates:

1. **`fct_orders`** (`order_id`, `customer_sk`, `order_date`, `amount`): one row
   per order, where `customer_sk` is the version of the customer that was valid
   on `order_date`. Use -1 when no version of that customer was valid on that
   date, including when the customer is not in the dimension at all.
2. **`rpt_revenue_by_tier_historical`** (`tier`, `revenue`): total order amount
   by the tier the customer had when they ordered (orders on -1 count as
   `'Unknown'`).
3. **`rpt_revenue_by_tier_current`** (`tier`, `revenue`): total order amount by
   each customer's current tier, regardless of when they ordered. Orders from
   customers that are not in the dimension count as `'Unknown'`.

Do not modify the existing tables. Return only the SQL script.
