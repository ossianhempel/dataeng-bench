-- Hashes raw keys and appends every staged row to the satellite.
CREATE TABLE hub_customer AS
SELECT md5(customer_number) AS customer_hk, customer_number, min(load_ts) AS load_ts, min(record_source) AS record_source
FROM stg_customers GROUP BY customer_number;
CREATE TABLE hub_order AS
SELECT md5(order_number) AS order_hk, order_number, min(load_ts) AS load_ts, min(record_source) AS record_source
FROM stg_orders GROUP BY order_number;
CREATE TABLE link_customer_order AS
SELECT md5(customer_number || '||' || order_number) AS customer_order_hk, md5(customer_number) AS customer_hk,
       md5(order_number) AS order_hk, min(load_ts) AS load_ts, min(record_source) AS record_source
FROM stg_orders GROUP BY customer_number, order_number;
CREATE TABLE sat_customer_details AS
SELECT md5(customer_number) AS customer_hk, load_ts, md5(name || '||' || email) AS hash_diff, name, email, record_source
FROM stg_customers;
