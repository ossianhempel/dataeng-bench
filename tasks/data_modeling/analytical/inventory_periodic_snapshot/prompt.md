# Build a daily inventory snapshot

DuckDB holds a product list, opening stock levels and stock movements:

```sql
CREATE TABLE raw_products (sku VARCHAR, product_name VARCHAR);

-- Quantity on hand at the start of 2024-01-01, before any movement that day.
-- Products without a row here start at 0.
CREATE TABLE raw_opening_balance (sku VARCHAR, quantity INTEGER);

-- Each receipt (positive) or issue (negative) of stock.
CREATE TABLE raw_inventory_movements (movement_ts TIMESTAMP, sku VARCHAR, quantity_delta INTEGER);
```

## Your task

Write a DuckDB SQL script that creates:

1. **`fct_inventory_daily`** (`snapshot_date`, `sku`, `quantity_on_hand`,
   `net_change`): a periodic snapshot with one row for every product in
   `raw_products` and every day from 2024-01-01 to 2024-01-10 inclusive, even on
   days without movements. `quantity_on_hand` is the quantity at the end of the
   day; `net_change` is the sum of that day's movements (0 if none).
   `snapshot_date` is a DATE. Ignore movements after 2024-01-10.
2. **`rpt_avg_on_hand`** (`sku`, `avg_quantity_on_hand`): for each product, the
   average daily quantity on hand over those 10 days, rounded to 2 decimals.

Do not modify the raw tables. Return only the SQL script.
