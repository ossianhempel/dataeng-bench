-- Takes the status from the event with the highest event_id and measures lags
-- in elapsed 24-hour periods instead of calendar days.
CREATE TABLE fct_order_fulfillment AS
WITH m AS (
    SELECT order_id,
        max(event_ts) FILTER (WHERE event_type = 'placed')    AS placed_at,
        max(event_ts) FILTER (WHERE event_type = 'paid')      AS paid_at,
        max(event_ts) FILTER (WHERE event_type = 'shipped')   AS shipped_at,
        max(event_ts) FILTER (WHERE event_type = 'delivered') AS delivered_at,
        max(event_ts) FILTER (WHERE event_type = 'cancelled') AS cancelled_at,
        arg_max(event_type, event_id) AS current_status
    FROM raw_order_events GROUP BY order_id
)
SELECT order_id, placed_at, paid_at, shipped_at, delivered_at, cancelled_at,
       CAST(floor(epoch(shipped_at - placed_at) / 86400) AS INTEGER) AS days_placed_to_shipped,
       CAST(floor(epoch(delivered_at - placed_at) / 86400) AS INTEGER) AS days_placed_to_delivered,
       current_status
FROM m;
