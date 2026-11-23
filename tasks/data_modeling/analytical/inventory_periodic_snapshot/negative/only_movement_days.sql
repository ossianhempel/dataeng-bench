-- Only emits rows on days with movements and averages over those rows,
-- so quiet days and products are missing from the snapshot.
CREATE TABLE fct_inventory_daily AS
WITH m AS (
    SELECT CAST(movement_ts AS DATE) AS snapshot_date, sku, sum(quantity_delta) AS net_change
    FROM raw_inventory_movements WHERE movement_ts < TIMESTAMP '2024-01-11' GROUP BY 1, 2
)
SELECT m.snapshot_date, m.sku,
       coalesce(o.quantity, 0) + sum(m.net_change) OVER (PARTITION BY m.sku ORDER BY m.snapshot_date) AS quantity_on_hand,
       m.net_change
FROM m LEFT JOIN raw_opening_balance o USING (sku);
CREATE TABLE rpt_avg_on_hand AS
SELECT sku, round(avg(quantity_on_hand), 2) AS avg_quantity_on_hand FROM fct_inventory_daily GROUP BY sku;
