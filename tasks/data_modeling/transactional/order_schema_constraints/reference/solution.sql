CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    email       VARCHAR NOT NULL UNIQUE,
    full_name   VARCHAR NOT NULL,
    created_at  TIMESTAMP
);

CREATE TABLE products (
    sku        VARCHAR PRIMARY KEY,
    name       VARCHAR NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE orders (
    order_id    INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers (customer_id),
    status      VARCHAR NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending', 'paid', 'shipped', 'cancelled')),
    ordered_at  TIMESTAMP NOT NULL,
    shipped_at  TIMESTAMP,
    CHECK (shipped_at IS NULL OR shipped_at >= ordered_at),
    CHECK (status <> 'shipped' OR shipped_at IS NOT NULL)
);

CREATE TABLE order_items (
    order_id    INTEGER NOT NULL REFERENCES orders (order_id),
    line_number INTEGER NOT NULL CHECK (line_number >= 1),
    sku         VARCHAR NOT NULL REFERENCES products (sku),
    quantity    INTEGER NOT NULL CHECK (quantity > 0),
    unit_price  DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    PRIMARY KEY (order_id, line_number),
    UNIQUE (order_id, sku)
);
