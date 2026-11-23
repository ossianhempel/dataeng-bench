# Allocate joint account balances to customer segments

A bank's accounts can have several holders. DuckDB holds:

```sql
CREATE TABLE accounts  (account_id VARCHAR, balance DECIMAL(12, 2));
CREATE TABLE customers (customer_id VARCHAR, segment VARCHAR);   -- 'retail', 'private', 'business'
CREATE TABLE account_holders (
    account_id    VARCHAR,
    customer_id   VARCHAR,
    ownership_pct DECIMAL(5, 2)  -- e.g. 60.00 means 60 %; see below
);
```

For each account, either every holder has an `ownership_pct` (and they add up
to 100), or none do. When none do, the holders own equal shares.

## Your task

Write a DuckDB SQL script that creates:

1. **`bridge_account_customer`** (`account_id`, `customer_id`,
   `weighting_factor`): one row per account holder. `weighting_factor` is the
   holder's share as a fraction, and the factors of each account sum to 1.
2. **`rpt_balance_by_segment`** (`segment`, `allocated_balance`,
   `account_count`): `allocated_balance` is the total balance allocated to
   customers of that segment by their share, rounded to 2 decimals, so that the
   segments add up to the bank's total balance. `account_count` is the number of
   distinct accounts with at least one holder in that segment.

Do not modify the source tables. Return only the SQL script.
