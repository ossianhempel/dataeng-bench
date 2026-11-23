CREATE TABLE promotions (
    promotion_id VARCHAR,
    store_id     VARCHAR,
    sku          VARCHAR,
    start_date   DATE,
    end_date     DATE      -- inclusive
);
INSERT INTO promotions VALUES
    ('PR1', 'S1', 'A', DATE '2024-05-01', DATE '2024-05-03'),
    ('PR1', 'S2', 'A', DATE '2024-05-01', DATE '2024-05-03'),
    ('PR2', 'S1', 'B', DATE '2024-05-02', DATE '2024-05-04'),
    ('PR3', 'S2', 'C', DATE '2024-05-05', DATE '2024-05-05');

CREATE TABLE sales (sale_date DATE, store_id VARCHAR, sku VARCHAR, quantity INTEGER);
INSERT INTO sales VALUES
    (DATE '2024-05-01', 'S1', 'A', 3),
    (DATE '2024-05-02', 'S1', 'A', 1),
    (DATE '2024-05-04', 'S2', 'A', 5),
    (DATE '2024-04-30', 'S1', 'B', 2),
    (DATE '2024-05-05', 'S1', 'B', 1),
    (DATE '2024-05-06', 'S2', 'C', 2),
    (DATE '2024-05-03', 'S1', 'C', 4);
