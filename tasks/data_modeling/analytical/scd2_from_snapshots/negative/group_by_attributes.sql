-- Groups by attribute values, which merges C1's two separate 'silver' periods,
-- ignores deletes and keeps the email that was current in each period.
CREATE TABLE dim_customer_scd2 AS
WITH v AS (
    SELECT customer_id, max(email) AS email, tier, city, min(snapshot_date) AS valid_from
    FROM raw_customer_snapshots
    GROUP BY customer_id, tier, city
)
SELECT *,
       lead(valid_from) OVER (PARTITION BY customer_id ORDER BY valid_from) AS valid_to,
       lead(valid_from) OVER (PARTITION BY customer_id ORDER BY valid_from) IS NULL AS is_current
FROM v;
