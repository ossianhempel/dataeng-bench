-- Checks only whether the product ever sold in the store, ignoring the promotion window.
CREATE TABLE fct_promotion_coverage AS
SELECT start_date AS coverage_date, promotion_id, store_id, sku FROM promotions;
CREATE TABLE rpt_promoted_not_sold AS
SELECT p.promotion_id, p.store_id, p.sku FROM promotions p
WHERE NOT EXISTS (SELECT 1 FROM sales s WHERE s.store_id = p.store_id AND s.sku = p.sku);
