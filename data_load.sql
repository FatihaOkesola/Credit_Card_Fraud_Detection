-- Drop existing tables
DROP TABLE IF EXISTS Fraud_Flags;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Users;

-- Create Users
CREATE TABLE Users (
    user_id VARCHAR(50) PRIMARY KEY,
    user_account_age_days INT,
    user_prev_chargebacks INT,
    user_is_high_risk BOOLEAN,
    email_domain VARCHAR(100)
);

-- Create Transactions
CREATE TABLE Transactions (
    transaction_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES Users(user_id),
    timestamp_utc TIMESTAMP,
    local_hour INT,
    amount_aed NUMERIC(10,2),
    currency VARCHAR(10),
    merchant_category VARCHAR(50),
    items_count INT,
    avg_item_price NUMERIC(10,2),
    payment_method VARCHAR(50),
    card_present BOOLEAN,
    card_age_days INT,
    bin_country VARCHAR(10),
    card_country_match BOOLEAN,
    device_type VARCHAR(20),
    browser VARCHAR(50),
    ip_address VARCHAR(20),
    ip_risk_score NUMERIC(5,2),
    odd_hour BOOLEAN,
    shipping_city VARCHAR(50),
    billing_city VARCHAR(50),
    shipping_billing_match BOOLEAN,
    transactions_last_1h INT,
    transactions_last_24h INT,
    is_fraud BOOLEAN
);

-- Create Fraud_Flags
CREATE TABLE Fraud_Flags (
    transaction_id VARCHAR(50) PRIMARY KEY REFERENCES Transactions(transaction_id),
    fraud_flag_ip BOOLEAN,
    fraud_flag_mismatch BOOLEAN,
    fraud_flag_velocity BOOLEAN,
    fraud_flag_new_account BOOLEAN,
    fraud_flag_prev_cb BOOLEAN,
    fraud_flag_odd_hour BOOLEAN
);

CREATE TABLE staging (
    transaction_id VARCHAR(50),
    user_id VARCHAR(50),
    timestamp_utc TIMESTAMP,
    amount_aed NUMERIC(10,2),
    currency VARCHAR(10),
    payment_method VARCHAR(50),
    device_type VARCHAR(20),
    browser VARCHAR(50),
    merchant_category VARCHAR(50),
    items_count INT,
    avg_item_price NUMERIC(10,2),
    shipping_city VARCHAR(50),
    billing_city VARCHAR(50),
    shipping_billing_match BOOLEAN,
    ip_address VARCHAR(20),
    ip_risk_score NUMERIC(5,2),
    card_present BOOLEAN,
    bin_country VARCHAR(10),
    card_age_days INT,
    card_country_match BOOLEAN,
    email_domain VARCHAR(100),
    user_prev_chargebacks INT,
    user_is_high_risk BOOLEAN,
    user_account_age_days INT,
    transactions_last_24h INT,
    transactions_last_1h INT,
    local_hour INT,
    odd_hour BOOLEAN,
    is_fraud BOOLEAN,
    fraud_flag_ip BOOLEAN,
    fraud_flag_mismatch BOOLEAN,
    fraud_flag_velocity BOOLEAN,
    fraud_flag_new_account BOOLEAN,
    fraud_flag_prev_cb BOOLEAN,
    fraud_flag_odd_hour BOOLEAN,
    data_source VARCHAR(50)
);

SELECT COUNT(*) FROM staging;

-- Populate Users
INSERT INTO Users (user_id, user_account_age_days, user_prev_chargebacks, user_is_high_risk, email_domain)
SELECT DISTINCT ON (user_id) user_id, user_account_age_days, user_prev_chargebacks, user_is_high_risk, email_domain
FROM staging
ORDER BY user_id;

SELECT COUNT(*) FROM Users;

INSERT INTO Transactions (transaction_id, user_id, timestamp_utc, local_hour, amount_aed, currency, merchant_category, items_count, avg_item_price, payment_method, card_present, card_age_days, bin_country, card_country_match, device_type, browser, ip_address, ip_risk_score, odd_hour, shipping_city, billing_city, shipping_billing_match, transactions_last_1h, transactions_last_24h, is_fraud)
SELECT DISTINCT ON (transaction_id) transaction_id, user_id, timestamp_utc, local_hour, amount_aed, currency, merchant_category, items_count, avg_item_price, payment_method, card_present, card_age_days, bin_country, card_country_match, device_type, browser, ip_address, ip_risk_score, odd_hour, shipping_city, billing_city, shipping_billing_match, transactions_last_1h, transactions_last_24h, is_fraud
FROM staging
ORDER BY transaction_id;

INSERT INTO Fraud_Flags (transaction_id, fraud_flag_ip, fraud_flag_mismatch, fraud_flag_velocity, fraud_flag_new_account, fraud_flag_prev_cb, fraud_flag_odd_hour)
SELECT DISTINCT ON (transaction_id) transaction_id, fraud_flag_ip, fraud_flag_mismatch, fraud_flag_velocity, fraud_flag_new_account, fraud_flag_prev_cb, fraud_flag_odd_hour
FROM staging
ORDER BY transaction_id;

SELECT 'Users' AS table_name, COUNT(*) AS row_count FROM Users
UNION ALL
SELECT 'Transactions', COUNT(*) FROM Transactions
UNION ALL
SELECT 'Fraud_Flags', COUNT(*) FROM Fraud_Flags;

SELECT 
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_fraud = TRUE THEN 1 ELSE 0 END) AS fraud_count,
    ROUND(SUM(CASE WHEN is_fraud = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS fraud_rate_pct
FROM Transactions;