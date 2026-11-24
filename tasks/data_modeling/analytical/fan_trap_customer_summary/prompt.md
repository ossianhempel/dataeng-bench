# Build a customer summary

DuckDB holds these tables from a shop:

```sql
CREATE TABLE customers   (customer_id VARCHAR, name VARCHAR);
CREATE TABLE orders      (order_id INTEGER, customer_id VARCHAR, order_amount DECIMAL(10, 2));
CREATE TABLE order_items (order_id INTEGER, sku VARCHAR, quantity INTEGER);
CREATE TABLE payments    (payment_id INTEGER, order_id INTEGER, amount DECIMAL(10, 2));
```

An order has one or more items and zero or more payments (customers can split
a payment or pay later).

## Your task

Write a DuckDB SQL script that creates `rpt_customer_summary` with one row per
customer in `customers`, including customers with no orders, and these columns:

| column | meaning |
|---|---|
| `customer_id` | |
| `order_count` | number of orders |
| `items_ordered` | total quantity across all their order items |
| `order_value` | total `order_amount` of their orders |
| `amount_paid` | total of payments on their orders |

Use 0, not NULL, when a customer has nothing to count. Do not modify the source
tables. Return only the SQL script.
