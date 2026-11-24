CREATE TABLE stg_customers (
    customer_number VARCHAR,
    name            VARCHAR,
    email           VARCHAR,
    load_ts         TIMESTAMP,
    record_source   VARCHAR
);
INSERT INTO stg_customers VALUES
    ('C-001',  'Ana Alm',  'ana@mail.test',  TIMESTAMP '2024-01-01 00:00:00', 'crm'),
    (' c-002', 'Ben Berg', 'BEN@mail.test',  TIMESTAMP '2024-01-01 00:00:00', 'crm'),
    ('C-003',  'Cai',      'cai@mail.test',  TIMESTAMP '2024-01-01 00:00:00', 'crm'),
    ('C-001',  'Ana Alm',  'ana@mail.test',  TIMESTAMP '2024-01-02 00:00:00', 'crm'),
    ('C-002',  'Ben Berg', 'ben@mail.test ', TIMESTAMP '2024-01-02 00:00:00', 'crm'),
    ('C-003',  'Cai Dahl', 'cai@mail.test',  TIMESTAMP '2024-01-02 00:00:00', 'crm'),
    ('C-004',  'Dan Ek',   'dan@mail.test',  TIMESTAMP '2024-01-02 00:00:00', 'crm'),
    ('C-003',  'Cai',      'cai@mail.test',  TIMESTAMP '2024-01-03 00:00:00', 'crm');

CREATE TABLE stg_orders (
    order_number    VARCHAR,
    customer_number VARCHAR,
    order_date      DATE,
    total           DECIMAL(10, 2),
    load_ts         TIMESTAMP,
    record_source   VARCHAR
);
INSERT INTO stg_orders VALUES
    ('O-1', 'C-001',   DATE '2023-12-31', 40.00, TIMESTAMP '2024-01-01 00:00:00', 'webshop'),
    ('o-2', 'c-002 ',  DATE '2023-12-31', 15.00, TIMESTAMP '2024-01-01 00:00:00', 'webshop'),
    ('O-1', 'C-001',   DATE '2023-12-31', 40.00, TIMESTAMP '2024-01-02 00:00:00', 'webshop'),
    ('O-3', 'C-004',   DATE '2024-01-01', 99.00, TIMESTAMP '2024-01-02 00:00:00', 'webshop');
