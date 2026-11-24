# Load a Data Vault

Staging tables in DuckDB hold three daily batches (`load_ts` is the batch time)
from a CRM and a webshop:

```sql
CREATE TABLE stg_customers (
    customer_number VARCHAR,     -- business key; casing and spacing vary between batches
    name            VARCHAR,
    email           VARCHAR,
    load_ts         TIMESTAMP,
    record_source   VARCHAR
);

CREATE TABLE stg_orders (
    order_number    VARCHAR,     -- business key; casing and spacing vary
    customer_number VARCHAR,
    order_date      DATE,
    total           DECIMAL(10, 2),
    load_ts         TIMESTAMP,
    record_source   VARCHAR
);
```

A batch can re-send records that were already loaded.

## Conventions

- Normalize a business key as `upper(trim(key))`. Hubs store the normalized key.
- Hash keys are DuckDB `md5()` of the normalized key. A link hash key is the
  md5 of the normalized keys joined with `'||'`, in the order customer, order:
  `md5(upper(trim(customer_number)) || '||' || upper(trim(order_number)))`.
- The satellite hash diff is
  `md5(coalesce(trim(name), '') || '||' || coalesce(lower(trim(email)), ''))`,
  and the satellite stores `trim(name)` and `lower(trim(email))`.
- `load_ts` and `record_source` on hubs and links come from the first batch in
  which the key (or key combination) appeared.

## Your task

Write a DuckDB SQL script that creates and loads:

1. **`hub_customer`** (`customer_hk`, `customer_number`, `load_ts`, `record_source`)
2. **`hub_order`** (`order_hk`, `order_number`, `load_ts`, `record_source`)
3. **`link_customer_order`** (`customer_order_hk`, `customer_hk`, `order_hk`, `load_ts`, `record_source`)
4. **`sat_customer_details`** (`customer_hk`, `load_ts`, `hash_diff`, `name`, `email`, `record_source`):
   insert-only history. A customer gets a new satellite row in a batch only
   when its hash diff differs from that customer's most recent earlier
   satellite row (or when it has none).

Hubs and links hold one row per distinct key. Do not modify the staging tables.
Return only the SQL script.
