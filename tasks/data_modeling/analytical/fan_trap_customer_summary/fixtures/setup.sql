CREATE TABLE customers (customer_id VARCHAR, name VARCHAR);
INSERT INTO customers VALUES ('C1', 'Ana'), ('C2', 'Ben'), ('C3', 'Cai');

CREATE TABLE orders (order_id INTEGER, customer_id VARCHAR, order_amount DECIMAL(10, 2));
INSERT INTO orders VALUES (1, 'C1', 100.00), (2, 'C1', 50.00), (3, 'C2', 80.00);

CREATE TABLE order_items (order_id INTEGER, sku VARCHAR, quantity INTEGER);
INSERT INTO order_items VALUES
    (1, 'A', 2), (1, 'B', 1),
    (2, 'A', 1),
    (3, 'C', 1), (3, 'D', 2), (3, 'E', 1);

CREATE TABLE payments (payment_id INTEGER, order_id INTEGER, amount DECIMAL(10, 2));
INSERT INTO payments VALUES (1, 1, 60.00), (2, 1, 40.00), (3, 3, 80.00);
