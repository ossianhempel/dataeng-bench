CREATE TABLE fct_order_fulfillment AS
WITH milestones AS (
    SELECT
        order_id,
        min(event_ts) FILTER (WHERE event_type = 'placed')    AS placed_at,
        min(event_ts) FILTER (WHERE event_type = 'paid')      AS paid_at,
        min(event_ts) FILTER (WHERE event_type = 'shipped')   AS shipped_at,
        min(event_ts) FILTER (WHERE event_type = 'delivered') AS delivered_at,
        min(event_ts) FILTER (WHERE event_type = 'cancelled') AS cancelled_at
    FROM raw_order_events
    GROUP BY order_id
)
SELECT
    order_id,
    placed_at,
    paid_at,
    shipped_at,
    delivered_at,
    cancelled_at,
    date_diff('day', CAST(placed_at AS DATE), CAST(shipped_at AS DATE))   AS days_placed_to_shipped,
    date_diff('day', CAST(placed_at AS DATE), CAST(delivered_at AS DATE)) AS days_placed_to_delivered,
    CASE
        WHEN cancelled_at IS NOT NULL THEN 'cancelled'
        WHEN delivered_at IS NOT NULL THEN 'delivered'
        WHEN shipped_at IS NOT NULL THEN 'shipped'
        WHEN paid_at IS NOT NULL THEN 'paid'
        ELSE 'placed'
    END AS current_status
FROM milestones
WHERE placed_at IS NOT NULL;
