# Build an order-line fact table

Two raw tables are loaded into DuckDB from an e-commerce system:

```sql
CREATE TABLE raw_orders (
    order_id    INTEGER,
    customer_id VARCHAR,
    order_ts    TIMESTAMP,
    status      VARCHAR      -- 'completed' or 'cancelled'
);

CREATE TABLE raw_order_lines (
    order_id        INTEGER,
    line_number     INTEGER,
    product_sku     VARCHAR,
    quantity        INTEGER,
    unit_price      DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),  -- NULL means no discount
    _loaded_at      TIMESTAMP        -- when the loader delivered this row
);
```

The loader delivers at least once: the same order line (same `order_id` and
`line_number`) can arrive more than once. When it does, the delivery with the
latest `_loaded_at` is the correct version of that line.

## Your task

Write a DuckDB SQL script that creates a table `fct_order_lines` with exactly one
row per order line, for orders that exist in `raw_orders` and are not cancelled.
Columns:

| column | meaning |
|---|---|
| `order_id` | |
| `line_number` | |
| `customer_id` | from the order |
| `product_sku` | |
| `order_date` | the calendar date (DATE) of `order_ts` |
| `quantity` | |
| `gross_amount` | `quantity * unit_price` |
| `discount_amount` | 0 when the source has no discount |
| `net_amount` | `gross_amount - discount_amount` |

Do not modify the raw tables. Return only the SQL script.
