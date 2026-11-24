-- Ignores the weighting factor, so joint accounts are counted once per holder.
CREATE TABLE bridge_account_customer AS
SELECT account_id, customer_id, 1.0 AS weighting_factor FROM account_holders;
CREATE TABLE rpt_balance_by_segment AS
SELECT c.segment, sum(a.balance) AS allocated_balance, count(DISTINCT a.account_id) AS account_count
FROM account_holders h JOIN accounts a USING (account_id) JOIN customers c USING (customer_id)
GROUP BY c.segment;
