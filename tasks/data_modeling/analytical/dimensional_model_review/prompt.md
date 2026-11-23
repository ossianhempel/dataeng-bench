# Review a sales data model

A colleague built this model for sales reporting in the warehouse and asks for
your review before it goes live.

```sql
-- One table for all sales reporting
CREATE TABLE fct_sales (
    sale_key          VARCHAR,     -- order_id || '-' || coalesce(line_number, 'H')
    order_id          VARCHAR,
    line_number       INTEGER,     -- NULL on the order header row
    row_type          VARCHAR,     -- 'header' or 'line'
    order_date        VARCHAR,     -- 'DD/MM/YYYY' as text
    customer_id       VARCHAR,     -- NULL for guest checkouts
    customer_name     VARCHAR,
    customer_segment  VARCHAR,     -- the customer's segment today
    product_id        VARCHAR,     -- NULL on header rows
    product_category  VARCHAR,
    quantity          INTEGER,     -- NULL on header rows
    line_amount       DECIMAL,     -- NULL on header rows
    shipping_fee      DECIMAL,     -- order-level fee, repeated on the header and every line
    order_total       DECIMAL,     -- order-level total, repeated on the header and every line
    margin_pct        DECIMAL      -- line margin %
);

CREATE TABLE dim_product (
    product_key   VARCHAR,          -- category_code || '-' || product_id, e.g. 'KIT-123'
    product_id    VARCHAR,
    category_id   INTEGER           -- join dim_category, which joins dim_department
);
```

Business users will ask questions such as revenue by month and category,
shipping fees by customer segment at the time of the order, average margin, and
order counts.

Identify the problems in this design, explain the wrong answers or maintenance
pain each one causes, and propose a corrected model (tables, grain and keys).
