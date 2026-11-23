CREATE TABLE dim_customer (
    customer_sk INTEGER,
    customer_id VARCHAR,
    tier        VARCHAR,
    valid_from  DATE,
    valid_to    DATE,
    is_current  BOOLEAN
);
INSERT INTO dim_customer VALUES
    (-1, 'UNKNOWN', 'Unknown', NULL, NULL, TRUE),
    (1, 'C1', 'silver', DATE '2024-01-01', DATE '2024-02-01', FALSE),
    (2, 'C1', 'gold',   DATE '2024-02-01', NULL,              TRUE),
    (3, 'C2', 'bronze', DATE '2024-01-15', DATE '2024-03-01', FALSE),
    (4, 'C2', 'silver', DATE '2024-03-01', NULL,              TRUE),
    (5, 'C3', 'gold',   DATE '2024-01-01', NULL,              TRUE);

CREATE TABLE raw_orders (
    order_id    INTEGER,
    customer_id VARCHAR,
    order_date  DATE,
    amount      DECIMAL(10, 2)
);
INSERT INTO raw_orders VALUES
    (1, 'C1', DATE '2024-01-20', 100.00),
    (2, 'C1', DATE '2024-02-01', 200.00),
    (3, 'C2', DATE '2024-01-10',  50.00),
    (4, 'C2', DATE '2024-02-29',  80.00),
    (5, 'C2', DATE '2024-03-01', 120.00),
    (6, 'C3', DATE '2024-02-10', 300.00),
    (7, 'C9', DATE '2024-02-11',  40.00);
