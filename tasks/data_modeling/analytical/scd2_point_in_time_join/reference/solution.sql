CREATE TABLE fct_orders AS
SELECT
    o.order_id,
    coalesce(d.customer_sk, -1) AS customer_sk,
    o.order_date,
    o.amount
FROM raw_orders AS o
LEFT JOIN dim_customer AS d
    ON d.customer_id = o.customer_id
   AND d.customer_sk <> -1
   AND o.order_date >= d.valid_from
   AND (d.valid_to IS NULL OR o.order_date < d.valid_to);

CREATE TABLE rpt_revenue_by_tier_historical AS
SELECT d.tier, sum(f.amount) AS revenue
FROM fct_orders AS f
JOIN dim_customer AS d USING (customer_sk)
GROUP BY d.tier;

CREATE TABLE rpt_revenue_by_tier_current AS
SELECT coalesce(cur.tier, 'Unknown') AS tier, sum(o.amount) AS revenue
FROM raw_orders AS o
LEFT JOIN dim_customer AS cur
    ON cur.customer_id = o.customer_id AND cur.is_current AND cur.customer_sk <> -1
GROUP BY 1;
