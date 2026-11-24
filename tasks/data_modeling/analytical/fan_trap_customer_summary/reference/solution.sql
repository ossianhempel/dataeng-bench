CREATE TABLE rpt_customer_summary AS
WITH order_items_agg AS (
    SELECT order_id, sum(quantity) AS items
    FROM order_items
    GROUP BY order_id
),
payments_agg AS (
    SELECT order_id, sum(amount) AS paid
    FROM payments
    GROUP BY order_id
),
orders_enriched AS (
    SELECT o.order_id, o.customer_id, o.order_amount,
           coalesce(i.items, 0) AS items, coalesce(p.paid, 0) AS paid
    FROM orders AS o
    LEFT JOIN order_items_agg AS i USING (order_id)
    LEFT JOIN payments_agg AS p USING (order_id)
)
SELECT
    c.customer_id,
    count(o.order_id)                AS order_count,
    coalesce(sum(o.items), 0)        AS items_ordered,
    coalesce(sum(o.order_amount), 0) AS order_value,
    coalesce(sum(o.paid), 0)         AS amount_paid
FROM customers AS c
LEFT JOIN orders_enriched AS o USING (customer_id)
GROUP BY c.customer_id;
