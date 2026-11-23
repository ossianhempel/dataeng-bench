CREATE TABLE dim_customer AS
SELECT
    CAST(row_number() OVER (ORDER BY customer_id) AS INTEGER) AS customer_key,
    customer_id,
    name    AS customer_name,
    country
FROM raw_customers
UNION ALL
SELECT -1, 'UNKNOWN', 'Unknown', 'Unknown';

CREATE TABLE dim_product AS
SELECT
    CAST(row_number() OVER (ORDER BY sku) AS INTEGER) AS product_key,
    upper(trim(sku)) AS sku,
    product_name,
    category
FROM raw_products
UNION ALL
SELECT -1, 'UNKNOWN', 'Unknown', 'Unknown';

CREATE TABLE dim_date AS
SELECT
    CAST(strftime(d, '%Y%m%d') AS INTEGER) AS date_key,
    CAST(d AS DATE)                        AS full_date,
    year(d)                                AS year,
    quarter(d)                             AS quarter,
    month(d)                               AS month,
    monthname(d)                           AS month_name,
    dayname(d)                             AS day_of_week_name,
    isodow(d) IN (6, 7)                    AS is_weekend
FROM range(DATE '2024-01-01', DATE '2024-04-01', INTERVAL 1 DAY) AS t(d);

CREATE TABLE fct_sales AS
SELECT
    s.order_id,
    s.line_number,
    CAST(strftime(s.order_date, '%Y%m%d') AS INTEGER) AS date_key,
    coalesce(c.customer_key, -1)                       AS customer_key,
    coalesce(p.product_key, -1)                        AS product_key,
    s.quantity,
    s.net_amount
FROM raw_sales AS s
LEFT JOIN dim_customer AS c
    ON c.customer_id = s.customer_id AND c.customer_key > 0
LEFT JOIN dim_product AS p
    ON p.sku = upper(trim(s.product_sku)) AND p.product_key > 0;
