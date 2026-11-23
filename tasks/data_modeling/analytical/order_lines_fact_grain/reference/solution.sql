CREATE TABLE fct_order_lines AS
WITH latest_lines AS (
    SELECT *
    FROM raw_order_lines
    QUALIFY row_number() OVER (
        PARTITION BY order_id, line_number ORDER BY _loaded_at DESC
    ) = 1
)
SELECT
    l.order_id,
    l.line_number,
    o.customer_id,
    l.product_sku,
    CAST(o.order_ts AS DATE)                                          AS order_date,
    l.quantity,
    l.quantity * l.unit_price                                         AS gross_amount,
    coalesce(l.discount_amount, 0)                                    AS discount_amount,
    l.quantity * l.unit_price - coalesce(l.discount_amount, 0)        AS net_amount
FROM latest_lines AS l
JOIN raw_orders AS o ON o.order_id = l.order_id
WHERE o.status <> 'cancelled';
