CREATE TABLE raw_customer_snapshots (
    snapshot_date DATE,
    customer_id   VARCHAR,
    email         VARCHAR,
    tier          VARCHAR,
    city          VARCHAR
);
INSERT INTO raw_customer_snapshots VALUES
    -- 2024-01-01
    (DATE '2024-01-01', 'C1', 'a@mail.test',  'silver', 'Oslo'),
    (DATE '2024-01-01', 'C2', 'b@mail.test',  'bronze', NULL),
    -- 2024-01-02
    (DATE '2024-01-02', 'C1', 'a@mail.test',  'silver', 'Oslo'),
    (DATE '2024-01-02', 'C2', 'b@mail.test',  'bronze', NULL),
    (DATE '2024-01-02', 'C3', 'c@mail.test',  'silver', 'Lund'),
    -- 2024-01-03
    (DATE '2024-01-03', 'C1', 'a2@mail.test', 'silver', 'Oslo'),
    (DATE '2024-01-03', 'C2', 'b@mail.test',  'bronze', 'Bergen'),
    (DATE '2024-01-03', 'C3', 'c@mail.test',  'silver', 'Lund'),
    -- 2024-01-05 (no snapshot was taken on 2024-01-04)
    (DATE '2024-01-05', 'C1', 'a2@mail.test', 'gold',   'Oslo'),
    (DATE '2024-01-05', 'C2', 'b@mail.test',  'bronze', 'Bergen'),
    (DATE '2024-01-05', 'C4', 'd@mail.test',  'gold',   'Malmo'),
    -- 2024-01-08
    (DATE '2024-01-08', 'C1', 'a2@mail.test', 'silver', 'Oslo'),
    (DATE '2024-01-08', 'C2', 'b@mail.test',  'bronze', 'Bergen'),
    (DATE '2024-01-08', 'C4', 'd@mail.test',  'gold',   'Malmo');
