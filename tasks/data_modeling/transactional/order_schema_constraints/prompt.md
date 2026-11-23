# Enforce business rules in an order schema

You are designing the transactional database for a small web shop. Write DuckDB
DDL that creates the four tables below, with exactly these table and column
names. Choose the data types, keys, constraints and defaults so that the
database itself rejects any row that breaks a business rule, and accepts every
row that follows them.

## Tables and rules

**customers** (`customer_id`, `email`, `full_name`, `created_at`)

- `customer_id` (integer) identifies a customer.
- Every customer has an email and a full name. No two customers share an email.
- `created_at` is a timestamp and is optional.

**products** (`sku`, `name`, `unit_price`, `is_active`)

- `sku` (text) identifies a product. Every product has a name.
- Every product has a `unit_price` with two decimals. Free products (price 0) are allowed; negative prices are not.
- `is_active` is a boolean, always set, and is TRUE unless stated otherwise.

**orders** (`order_id`, `customer_id`, `status`, `ordered_at`, `shipped_at`)

- `order_id` (integer) identifies an order. Every order belongs to an existing customer.
- `status` is always set and is one of `pending`, `paid`, `shipped`, `cancelled`. A new order is `pending` unless stated otherwise.
- `ordered_at` is a timestamp and is always set.
- `shipped_at` is an optional timestamp. When present it cannot be earlier than `ordered_at`.
- An order with status `shipped` must have a `shipped_at`.

**order_items** (`order_id`, `line_number`, `sku`, `quantity`, `unit_price`)

- A line is identified by its order and its line number. Line numbers start at 1.
- Every line belongs to an existing order and refers to an existing product.
- `quantity` is a positive integer.
- `unit_price` (the price charged, two decimals) is always set and never negative.
- A product appears at most once per order.

Return only the SQL script.
