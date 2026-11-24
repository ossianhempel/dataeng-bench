CREATE TABLE raw_orders (
    order_id    INTEGER,
    customer_id VARCHAR,
    order_ts    TIMESTAMP,
    status      VARCHAR
);
INSERT INTO raw_orders VALUES
    (1001, 'C1', TIMESTAMP '2024-02-01 09:15:00', 'completed'),
    (1002, 'C2', TIMESTAMP '2024-02-01 23:50:00', 'completed'),
    (1003, 'C1', TIMESTAMP '2024-02-02 10:00:00', 'cancelled'),
    (1004, 'C3', TIMESTAMP '2024-02-03 14:30:00', 'completed');

CREATE TABLE raw_order_lines (
    order_id        INTEGER,
    line_number     INTEGER,
    product_sku     VARCHAR,
    quantity        INTEGER,
    unit_price      DECIMAL(10, 2),
    discount_amount DECIMAL(10, 2),
    _loaded_at      TIMESTAMP
);
INSERT INTO raw_order_lines VALUES
    (1001, 1, 'SKU-A', 2, 10.00, 0.00, TIMESTAMP '2024-02-01 10:00:00'),
    (1001, 2, 'SKU-B', 1, 25.00, 5.00, TIMESTAMP '2024-02-01 10:00:00'),
    (1001, 2, 'SKU-B', 1, 25.00, 5.00, TIMESTAMP '2024-02-02 10:00:00'),
    (1002, 1, 'SKU-A', 1, 10.00, NULL, TIMESTAMP '2024-02-02 10:00:00'),
    (1003, 1, 'SKU-C', 4, 7.50, 0.00, TIMESTAMP '2024-02-02 11:00:00'),
    (1004, 1, 'SKU-C', 1, 7.50, 0.00, TIMESTAMP '2024-02-03 15:00:00'),
    (1004, 1, 'SKU-C', 3, 7.50, 0.00, TIMESTAMP '2024-02-04 09:00:00'),
    (1004, 2, 'SKU-A', 5, 10.00, 2.50, TIMESTAMP '2024-02-03 15:00:00'),
    (1005, 1, 'SKU-B', 2, 25.00, 0.00, TIMESTAMP '2024-02-04 09:00:00');
