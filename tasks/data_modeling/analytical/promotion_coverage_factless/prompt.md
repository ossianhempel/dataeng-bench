# Promotion coverage

DuckDB holds the promotions plan and daily sales:

```sql
CREATE TABLE promotions (
    promotion_id VARCHAR,
    store_id     VARCHAR,
    sku          VARCHAR,
    start_date   DATE,
    end_date     DATE      -- inclusive
);

-- Only days with sales have rows.
CREATE TABLE sales (sale_date DATE, store_id VARCHAR, sku VARCHAR, quantity INTEGER);
```

The merchandising team asks: which products were on promotion in a store but
did not sell there at all while the promotion ran?

## Your task

Write a DuckDB SQL script that creates:

1. **`fct_promotion_coverage`** (`coverage_date`, `promotion_id`, `store_id`,
   `sku`): a factless fact table with one row for each day a product was on
   promotion in a store.
2. **`rpt_promoted_not_sold`** (`promotion_id`, `store_id`, `sku`): one row per
   promoted product and store with no sales on any day of that promotion.

Do not modify the source tables. Return only the SQL script.
