CREATE TABLE raw_products (sku VARCHAR, product_name VARCHAR);
INSERT INTO raw_products VALUES ('P1', 'Bolt'), ('P2', 'Nut'), ('P3', 'Washer');

-- Quantity on hand at the start of 2024-01-01, before any movement that day.
CREATE TABLE raw_opening_balance (sku VARCHAR, quantity INTEGER);
INSERT INTO raw_opening_balance VALUES ('P1', 10), ('P2', 0);

CREATE TABLE raw_inventory_movements (movement_ts TIMESTAMP, sku VARCHAR, quantity_delta INTEGER);
INSERT INTO raw_inventory_movements VALUES
    (TIMESTAMP '2024-01-01 09:00:00', 'P1', -3),
    (TIMESTAMP '2024-01-01 15:00:00', 'P1',  5),
    (TIMESTAMP '2024-01-03 11:00:00', 'P1', -4),
    (TIMESTAMP '2024-01-07 08:30:00', 'P1', -8),
    (TIMESTAMP '2024-01-11 10:00:00', 'P1', 100),
    (TIMESTAMP '2024-01-02 10:00:00', 'P2', 20),
    (TIMESTAMP '2024-01-05 09:00:00', 'P2', -5),
    (TIMESTAMP '2024-01-05 17:00:00', 'P2', -5),
    (TIMESTAMP '2024-01-04 12:00:00', 'P3',  7),
    (TIMESTAMP '2024-01-10 23:59:00', 'P3', -2);
