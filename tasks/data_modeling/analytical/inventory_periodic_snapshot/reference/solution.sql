CREATE TABLE fct_inventory_daily AS
WITH days AS (
    SELECT CAST(d AS DATE) AS snapshot_date
    FROM range(DATE '2024-01-01', DATE '2024-01-11', INTERVAL 1 DAY) AS t(d)
),
daily_moves AS (
    SELECT CAST(movement_ts AS DATE) AS snapshot_date, sku, sum(quantity_delta) AS net_change
    FROM raw_inventory_movements
    WHERE movement_ts < TIMESTAMP '2024-01-11 00:00:00'
    GROUP BY 1, 2
),
grid AS (
    SELECT d.snapshot_date, p.sku, coalesce(m.net_change, 0) AS net_change
    FROM days AS d
    CROSS JOIN raw_products AS p
    LEFT JOIN daily_moves AS m ON m.snapshot_date = d.snapshot_date AND m.sku = p.sku
)
SELECT
    g.snapshot_date,
    g.sku,
    CAST(coalesce(o.quantity, 0)
         + sum(g.net_change) OVER (PARTITION BY g.sku ORDER BY g.snapshot_date) AS INTEGER) AS quantity_on_hand,
    CAST(g.net_change AS INTEGER) AS net_change
FROM grid AS g
LEFT JOIN raw_opening_balance AS o ON o.sku = g.sku;

CREATE TABLE rpt_avg_on_hand AS
SELECT sku, round(avg(quantity_on_hand), 2) AS avg_quantity_on_hand
FROM fct_inventory_daily
GROUP BY sku;
