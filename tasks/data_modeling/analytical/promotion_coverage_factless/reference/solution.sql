CREATE TABLE fct_promotion_coverage AS
SELECT
    CAST(d.coverage_date AS DATE) AS coverage_date,
    p.promotion_id,
    p.store_id,
    p.sku
FROM promotions AS p,
     LATERAL (
         SELECT unnest(generate_series(p.start_date, p.end_date, INTERVAL 1 DAY)) AS coverage_date
     ) AS d;

CREATE TABLE rpt_promoted_not_sold AS
SELECT c.promotion_id, c.store_id, c.sku
FROM fct_promotion_coverage AS c
LEFT JOIN sales AS s
    ON s.sale_date = c.coverage_date AND s.store_id = c.store_id AND s.sku = c.sku
GROUP BY c.promotion_id, c.store_id, c.sku
HAVING count(s.sku) = 0;
