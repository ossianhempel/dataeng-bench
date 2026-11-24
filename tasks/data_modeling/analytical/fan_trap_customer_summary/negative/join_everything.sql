-- Joins both one-to-many children at once, so items and payments multiply each other.
CREATE TABLE rpt_customer_summary AS
SELECT c.customer_id,
       count(DISTINCT o.order_id) AS order_count,
       coalesce(sum(i.quantity), 0) AS items_ordered,
       coalesce(sum(o.order_amount), 0) AS order_value,
       coalesce(sum(p.amount), 0) AS amount_paid
FROM customers c
LEFT JOIN orders o USING (customer_id)
LEFT JOIN order_items i USING (order_id)
LEFT JOIN payments p USING (order_id)
GROUP BY c.customer_id;
