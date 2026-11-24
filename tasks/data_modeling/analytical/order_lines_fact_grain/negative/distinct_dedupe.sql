-- DISTINCT removes exact duplicates but keeps both versions of a corrected line.
CREATE TABLE fct_order_lines AS
SELECT DISTINCT
    l.order_id, l.line_number, o.customer_id, l.product_sku,
    CAST(o.order_ts AS DATE) AS order_date, l.quantity,
    l.quantity * l.unit_price AS gross_amount,
    coalesce(l.discount_amount, 0) AS discount_amount,
    l.quantity * l.unit_price - coalesce(l.discount_amount, 0) AS net_amount
FROM raw_order_lines l
JOIN raw_orders o USING (order_id)
WHERE o.status <> 'cancelled';
