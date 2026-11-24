CREATE TABLE raw_order_events (
    event_id   INTEGER,
    order_id   INTEGER,
    event_type VARCHAR,
    event_ts   TIMESTAMP
);
INSERT INTO raw_order_events VALUES
    (1,  1, 'placed',    TIMESTAMP '2024-01-01 10:00:00'),
    (2,  1, 'paid',      TIMESTAMP '2024-01-01 10:05:00'),
    (3,  1, 'shipped',   TIMESTAMP '2024-01-03 08:00:00'),
    (4,  1, 'delivered', TIMESTAMP '2024-01-05 14:00:00'),
    (5,  2, 'placed',    TIMESTAMP '2024-01-02 22:00:00'),
    (6,  2, 'paid',      TIMESTAMP '2024-01-03 01:00:00'),
    (7,  2, 'shipped',   TIMESTAMP '2024-01-04 09:00:00'),
    (8,  3, 'placed',    TIMESTAMP '2024-01-03 12:00:00'),
    (9,  3, 'paid',      TIMESTAMP '2024-01-03 12:31:00'),
    (10, 3, 'paid',      TIMESTAMP '2024-01-03 12:30:00'),
    (11, 4, 'placed',    TIMESTAMP '2024-01-04 09:00:00'),
    (12, 4, 'cancelled', TIMESTAMP '2024-01-04 11:00:00'),
    (13, 5, 'delivered', TIMESTAMP '2024-01-09 10:00:00'),
    (14, 5, 'shipped',   TIMESTAMP '2024-01-06 10:00:00'),
    (15, 5, 'placed',    TIMESTAMP '2024-01-05 10:00:00'),
    (16, 5, 'paid',      TIMESTAMP '2024-01-05 10:10:00'),
    (17, 6, 'placed',    TIMESTAMP '2024-01-06 08:00:00'),
    (18, 6, 'paid',      TIMESTAMP '2024-01-06 08:02:00'),
    (19, 6, 'cancelled', TIMESTAMP '2024-01-07 16:00:00'),
    (20, 7, 'paid',      TIMESTAMP '2024-01-07 09:00:00');
