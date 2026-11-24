# Build a retail star schema

These raw tables are loaded into DuckDB:

```sql
CREATE TABLE raw_customers (customer_id VARCHAR, name VARCHAR, country VARCHAR);
CREATE TABLE raw_products  (sku VARCHAR, product_name VARCHAR, category VARCHAR);
CREATE TABLE raw_sales (
    order_id    INTEGER,
    line_number INTEGER,
    order_date  DATE,
    customer_id VARCHAR,   -- can be NULL (guest checkout) or not yet in raw_customers
    product_sku VARCHAR,   -- typed by hand in the source: case and spacing vary
    quantity    INTEGER,
    net_amount  DECIMAL(10, 2)
);
```

`raw_sales` has one row per order line. All sales fall in Q1 2024.
SKUs match `raw_products.sku` once trimmed and upper-cased. Some sales refer to
customers or products that are missing from the dimension sources.

## Your task

Write a DuckDB SQL script that builds a star schema:

**`dim_customer`** (`customer_key`, `customer_id`, `customer_name`, `country`):
one row per customer with a positive integer surrogate key, plus one unknown
member row with `customer_key = -1`, `customer_id = 'UNKNOWN'` and `'Unknown'`
for the name and country.

**`dim_product`** (`product_key`, `sku`, `product_name`, `category`): one row per
product with a positive integer surrogate key, plus an unknown member row with
`product_key = -1`, `sku = 'UNKNOWN'` and `'Unknown'` for the name and category.

**`dim_date`** (`date_key`, `full_date`, `year`, `quarter`, `month`,
`month_name`, `day_of_week_name`, `is_weekend`): one row per calendar day from
2024-01-01 to 2024-03-31. `date_key` is the integer `YYYYMMDD`; `month_name` and
`day_of_week_name` are English names such as `January` and `Monday`.

**`fct_sales`** (`order_id`, `line_number`, `date_key`, `customer_key`,
`product_key`, `quantity`, `net_amount`): one row per row of `raw_sales`. Every
foreign key must point at a dimension row. Sales whose customer or product
cannot be matched point at the unknown member.

Do not modify the raw tables. Return only the SQL script.
