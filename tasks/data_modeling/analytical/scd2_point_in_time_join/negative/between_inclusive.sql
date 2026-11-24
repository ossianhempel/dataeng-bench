-- BETWEEN treats valid_to as inclusive, so an order on a change date matches two versions,
-- and orders before the first version are dropped instead of going to -1.
CREATE TABLE fct_orders AS
SELECT o.order_id, d.customer_sk, o.order_date, o.amount
FROM raw_orders o
JOIN dim_customer d
  ON d.customer_id = o.customer_id
 AND o.order_date BETWEEN d.valid_from AND coalesce(d.valid_to, DATE '9999-12-31');
CREATE TABLE rpt_revenue_by_tier_historical AS
SELECT d.tier, sum(f.amount) AS revenue FROM fct_orders f JOIN dim_customer d USING (customer_sk) GROUP BY 1;
CREATE TABLE rpt_revenue_by_tier_current AS
SELECT d.tier, sum(f.amount) AS revenue FROM fct_orders f
JOIN dim_customer v USING (customer_sk)
JOIN dim_customer d ON d.customer_id = v.customer_id AND d.is_current
GROUP BY 1;
