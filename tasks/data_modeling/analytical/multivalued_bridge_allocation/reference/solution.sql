CREATE TABLE bridge_account_customer AS
SELECT
    account_id,
    customer_id,
    CASE
        WHEN count(ownership_pct) OVER (PARTITION BY account_id) = 0
            THEN 1.0 / count(*) OVER (PARTITION BY account_id)
        ELSE CAST(ownership_pct AS DOUBLE) / 100
    END AS weighting_factor
FROM account_holders;

CREATE TABLE rpt_balance_by_segment AS
SELECT
    c.segment,
    round(sum(a.balance * b.weighting_factor), 2) AS allocated_balance,
    count(DISTINCT a.account_id)                  AS account_count
FROM bridge_account_customer AS b
JOIN accounts AS a USING (account_id)
JOIN customers AS c USING (customer_id)
GROUP BY c.segment;
