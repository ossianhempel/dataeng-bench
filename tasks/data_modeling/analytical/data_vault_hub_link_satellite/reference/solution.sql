CREATE TABLE hub_customer AS
SELECT
    md5(bk)                      AS customer_hk,
    bk                           AS customer_number,
    min(load_ts)                 AS load_ts,
    arg_min(record_source, load_ts) AS record_source
FROM (SELECT upper(trim(customer_number)) AS bk, load_ts, record_source FROM stg_customers)
GROUP BY bk;

CREATE TABLE hub_order AS
SELECT
    md5(bk)                      AS order_hk,
    bk                           AS order_number,
    min(load_ts)                 AS load_ts,
    arg_min(record_source, load_ts) AS record_source
FROM (SELECT upper(trim(order_number)) AS bk, load_ts, record_source FROM stg_orders)
GROUP BY bk;

CREATE TABLE link_customer_order AS
SELECT
    md5(c_bk || '||' || o_bk)    AS customer_order_hk,
    md5(c_bk)                    AS customer_hk,
    md5(o_bk)                    AS order_hk,
    min(load_ts)                 AS load_ts,
    arg_min(record_source, load_ts) AS record_source
FROM (
    SELECT upper(trim(customer_number)) AS c_bk, upper(trim(order_number)) AS o_bk, load_ts, record_source
    FROM stg_orders
)
GROUP BY c_bk, o_bk;

CREATE TABLE sat_customer_details AS
WITH staged AS (
    SELECT
        md5(upper(trim(customer_number)))                                          AS customer_hk,
        load_ts,
        md5(coalesce(trim(name), '') || '||' || coalesce(lower(trim(email)), '')) AS hash_diff,
        trim(name)                                                                 AS name,
        lower(trim(email))                                                         AS email,
        record_source
    FROM stg_customers
),
compared AS (
    SELECT *, lag(hash_diff) OVER (PARTITION BY customer_hk ORDER BY load_ts) AS previous_hash_diff
    FROM staged
)
SELECT customer_hk, load_ts, hash_diff, name, email, record_source
FROM compared
WHERE previous_hash_diff IS DISTINCT FROM hash_diff;
