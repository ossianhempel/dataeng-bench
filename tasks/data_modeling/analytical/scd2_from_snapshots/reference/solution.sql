CREATE TABLE dim_customer_scd2 AS
WITH snapshot_dates AS (
    SELECT snapshot_date, lead(snapshot_date) OVER (ORDER BY snapshot_date) AS next_snapshot_date
    FROM (SELECT DISTINCT snapshot_date FROM raw_customer_snapshots)
),
flagged AS (
    SELECT
        s.*,
        CASE
            WHEN lag(s.snapshot_date) OVER w IS NULL THEN 1
            WHEN s.tier IS DISTINCT FROM lag(s.tier) OVER w
              OR s.city IS DISTINCT FROM lag(s.city) OVER w THEN 1
            ELSE 0
        END AS is_change
    FROM raw_customer_snapshots AS s
    WINDOW w AS (PARTITION BY s.customer_id ORDER BY s.snapshot_date)
),
versioned AS (
    SELECT *, sum(is_change) OVER (PARTITION BY customer_id ORDER BY snapshot_date) AS version_no
    FROM flagged
),
versions AS (
    SELECT
        customer_id,
        version_no,
        any_value(tier)    AS tier,
        any_value(city)    AS city,
        min(snapshot_date) AS valid_from,
        max(snapshot_date) AS last_seen
    FROM versioned
    GROUP BY customer_id, version_no
),
latest_email AS (
    SELECT customer_id, email
    FROM raw_customer_snapshots
    QUALIFY row_number() OVER (PARTITION BY customer_id ORDER BY snapshot_date DESC) = 1
),
bounded AS (
    SELECT
        v.*,
        lead(v.valid_from) OVER (PARTITION BY v.customer_id ORDER BY v.version_no) AS next_valid_from
    FROM versions AS v
)
SELECT
    b.customer_id,
    e.email,
    b.tier,
    b.city,
    b.valid_from,
    -- next version start, or the first snapshot after the customer was last seen
    -- (NULL when they are still in the latest snapshot)
    coalesce(b.next_valid_from, d.next_snapshot_date) AS valid_to,
    coalesce(b.next_valid_from, d.next_snapshot_date) IS NULL AS is_current
FROM bounded AS b
JOIN latest_email AS e USING (customer_id)
JOIN snapshot_dates AS d ON d.snapshot_date = b.last_seen;
