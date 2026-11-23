-- Declares keys and types but none of the business rules.
CREATE TABLE customers (customer_id INTEGER PRIMARY KEY, email VARCHAR, full_name VARCHAR, created_at TIMESTAMP);
CREATE TABLE products (sku VARCHAR PRIMARY KEY, name VARCHAR, unit_price DECIMAL(10, 2), is_active BOOLEAN DEFAULT TRUE);
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, customer_id INTEGER, status VARCHAR DEFAULT 'pending',
                     ordered_at TIMESTAMP, shipped_at TIMESTAMP);
CREATE TABLE order_items (order_id INTEGER, line_number INTEGER, sku VARCHAR, quantity INTEGER,
                          unit_price DECIMAL(10, 2), PRIMARY KEY (order_id, line_number));
