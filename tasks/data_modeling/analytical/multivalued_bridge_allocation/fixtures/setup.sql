CREATE TABLE accounts (account_id VARCHAR, balance DECIMAL(12, 2));
INSERT INTO accounts VALUES ('A1', 900.00), ('A2', 300.00), ('A3', 1000.00), ('A4', 50.00);

CREATE TABLE customers (customer_id VARCHAR, segment VARCHAR);
INSERT INTO customers VALUES ('K1', 'retail'), ('K2', 'retail'), ('K3', 'private'), ('K4', 'business');

CREATE TABLE account_holders (account_id VARCHAR, customer_id VARCHAR, ownership_pct DECIMAL(5, 2));
INSERT INTO account_holders VALUES
    ('A1', 'K1', NULL), ('A1', 'K2', NULL), ('A1', 'K3', NULL),
    ('A2', 'K1', 100.00),
    ('A3', 'K3', 60.00), ('A3', 'K4', 40.00),
    ('A4', 'K2', NULL), ('A4', 'K4', NULL);
