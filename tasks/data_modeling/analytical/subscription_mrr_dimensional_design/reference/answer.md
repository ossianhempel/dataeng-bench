## 1. Business processes, grain and fact types

| Fact table | Type | Grain |
|---|---|---|
| `fct_subscription_events` | Transaction | One row per subscription change event (trial started, activated, plan changed, seats changed, paused, resumed, cancelled, reactivated) |
| `fct_mrr_monthly` | Periodic snapshot | One row per subscription per calendar month (end-of-month state), including months where MRR is 0 right after churn |
| `fct_invoice_lines` | Transaction | One row per invoice or credit-note line (for billed revenue, not MRR) |

MRR is a balance, like an account balance, so it needs a periodic snapshot: summing
change events to get it at an arbitrary month is error-prone and slow. The event fact
keeps the detail for "why did MRR change".

## 2. Dimensions

- `dim_customer` (Type 2): customer_id, name, country, segment, acquisition_channel,
  first_paid_month. Type 2 so each monthly row points at the version valid at month end.
- `dim_plan`: plan_name, tier, billing_interval (monthly/annual), list price, currency.
- `dim_month` (role-playing `dim_date` at month grain).
- `dim_subscription` (degenerate or small dimension): subscription_id, start date, status.
- `fx_rates`: month, currency, rate_to_usd (budget rate fixed per fiscal year).

The snapshot row carries `customer_key` (the Type 2 version at month end) and `plan_key`
as of month end, so slicing "as they were at the time" is a simple join.

## 3. Measures

`fct_mrr_monthly`: `mrr_usd`, `mrr_local`, `seats`, `is_active`, and the movement
columns `new_mrr`, `expansion_mrr`, `contraction_mrr`, `churned_mrr`,
`reactivation_mrr`, plus `opening_mrr`.

- `mrr_usd`, `seats`, active counts: semi-additive. Sum across customers and plans in a
  month; never across months (use the month-end value or an average).
- Movement amounts: additive (a quarter's new MRR is the sum of its months).
- Churn rate, NRR, ARPA: non-additive ratios. Compute from additive numerators and
  denominators at the requested level.

## 4. MRR rules

- MRR = recurring subscription price at month end, after discounts, excluding taxes,
  one-off fees and usage charges.
- Annual plans: annual price / 12.
- Trials: 0 MRR; first paid month counts as new.
- Mid-month changes: the snapshot is taken at month end, so the new price shows in that
  month's row; proration affects invoices, not MRR.
- Pauses: MRR 0 while paused, and resuming counts as reactivation (stated policy).
- Currency: EUR converted with a fixed budget rate per fiscal year so FX moves do not
  appear as expansion or contraction; report FX at actual rates separately if needed.
- Refunds and credit notes: do not change MRR unless the recurring price changed.

## 5. Movements and metrics

For each subscription (or customer, for customer-level reporting) compare this month's
MRR `m` with last month's `p`:

- new: `p = 0`, never active before, `m > 0`
- reactivation: `p = 0`, active before, `m > 0`
- expansion: `p > 0`, `m > p` → `m - p`
- contraction: `p > 0`, `0 < m < p` → `p - m`
- churn: `p > 0`, `m = 0` → `p`

Check: opening + new + reactivation + expansion - contraction - churn = closing.

- Logo churn rate = customers with MRR > 0 last month and 0 this month / customers with
  MRR > 0 last month.
- NRR (monthly) = this month's MRR from customers active last month / last month's MRR
  of those customers. Annual NRR uses the cohort from 12 months earlier.

Edge cases: customers with several subscriptions (customer-level churn only when all end),
backdated cancellations (rebuild affected months and flag restatements), customers moving
segment (Type 2 keeps old months in the old segment), and month boundaries in UTC.
