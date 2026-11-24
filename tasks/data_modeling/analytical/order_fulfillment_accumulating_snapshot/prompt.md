# Build an order fulfillment accumulating snapshot

An event stream from the order service is loaded into DuckDB:

```sql
CREATE TABLE raw_order_events (
    event_id   INTEGER,
    order_id   INTEGER,
    event_type VARCHAR,     -- 'placed', 'paid', 'shipped', 'delivered', 'cancelled'
    event_ts   TIMESTAMP
);
```

Events can arrive out of order (`event_id` order is not time order), and the
same milestone can be recorded more than once for an order (for example a
retried payment).

## Your task

Write a DuckDB SQL script that creates `fct_order_fulfillment`, an accumulating
snapshot with one row per order that has a `placed` event (ignore orders without
one). Columns:

| column | meaning |
|---|---|
| `order_id` | |
| `placed_at`, `paid_at`, `shipped_at`, `delivered_at`, `cancelled_at` | timestamp of the earliest event of that type, NULL if none |
| `days_placed_to_shipped` | calendar days between the date of `placed_at` and the date of `shipped_at` (for example 2024-01-02 23:00 to 2024-01-04 01:00 is 2), NULL if not shipped |
| `days_placed_to_delivered` | same, to the date of `delivered_at` |
| `current_status` | `'cancelled'` if the order has a cancelled event; otherwise the furthest milestone reached, in the order placed < paid < shipped < delivered |

Do not modify the raw table. Return only the SQL script.
