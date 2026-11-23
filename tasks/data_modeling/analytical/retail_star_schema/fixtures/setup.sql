CREATE TABLE raw_customers (customer_id VARCHAR, name VARCHAR, country VARCHAR);
INSERT INTO raw_customers VALUES
    ('C1', 'Ana Alm', 'SE'),
    ('C2', 'Ben Berg', 'NO'),
    ('C3', 'Cai Dahl', 'SE');

CREATE TABLE raw_products (sku VARCHAR, product_name VARCHAR, category VARCHAR);
INSERT INTO raw_products VALUES
    ('SKU-A', 'Mug', 'Kitchen'),
    ('SKU-B', 'Lamp', 'Home'),
    ('SKU-C', 'Pan', 'Kitchen');

CREATE TABLE raw_sales (
    order_id    INTEGER,
    line_number INTEGER,
    order_date  DATE,
    customer_id VARCHAR,
    product_sku VARCHAR,
    quantity    INTEGER,
    net_amount  DECIMAL(10, 2)
);
INSERT INTO raw_sales VALUES
    (1, 1, DATE '2024-01-06', 'C1', 'sku-a ', 2, 20.00),
    (1, 2, DATE '2024-01-06', 'C1', 'SKU-B',  1, 45.00),
    (2, 1, DATE '2024-02-29', 'C2', 'SKU-C',  3, 60.00),
    (3, 1, DATE '2024-03-15', 'C9', 'SKU-A',  1, 10.00),
    (4, 1, DATE '2024-03-31', 'C3', 'SKU-Z',  2,  8.00),
    (5, 1, DATE '2024-01-10', NULL, ' Sku-b', 1, 45.00);
