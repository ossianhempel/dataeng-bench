# Model subscription revenue for a SaaS company

A B2B SaaS company sells plans (Starter, Team, Enterprise) billed monthly or
annually, in USD and EUR. Customers can start with a 14-day free trial, upgrade
or downgrade at any time (prorated), add seats, pause, cancel and come back.
Invoices, credit notes and plan changes are available from the billing system.

Leadership wants a monthly dashboard with:

- MRR (monthly recurring revenue) in USD, and MRR movements per month: new,
  expansion, contraction, churned and reactivated MRR.
- Customer counts: active, new, churned; logo churn rate and net revenue retention.
- All of the above sliced by plan, billing interval, customer country, customer
  segment and acquisition channel, as they were at the time.

Design the dimensional model. Cover:

1. The business process(es) and the grain of each fact table, and the fact
   table type you chose.
2. The dimensions, their key attributes, and how you handle attributes that
   change over time.
3. The measures, and which are additive, semi-additive or non-additive.
4. How MRR and each MRR movement is computed, including annual plans,
   mid-month changes, trials, pauses, currency and refunds.
5. How the dashboard's metrics are calculated from your tables.
