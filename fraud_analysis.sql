--Which merchant category has the highest fraud rate?
SELECT t.merchant_category, 
ROUND(SUM(CASE WHEN is_fraud = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS merchant_fraud_pct
FROM transactions AS t
GROUP BY t.merchant_category
ORDER BY merchant_fraud_pct DESC;

--Which device type has the highest fraud rate?
SELECT t.device_type,
ROUND(SUM(CASE WHEN is_fraud = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS device_fraud_pct
FROM transactions AS t
GROUP BY t.device_type
ORDER BY device_fraud_pct DESC;

--Which payment type has the highest fraud rate?
SELECT t.payment_method,
ROUND(SUM(CASE WHEN is_fraud = TRUE THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS payment_fraud_pct
FROM transactions AS t
GROUP BY t.payment_method
ORDER BY payment_fraud_pct DESC;

-- =============================================
-- SECTION A: CATEGORICAL FRAUD ANALYSIS
-- =============================================
-- INSIGHT:
-- Fraud rate was tested across three categorical variables:
-- merchant category (7.70% - 8.73%), device type (7.88% - 8.24%),
-- and payment method (8.03% - 8.69%).
-- In all three cases, the spread is less than 1%, indicating that
-- categorical variables alone are not strong fraud discriminators.
-- Fraud appears evenly distributed across categories, devices, and
-- payment methods, suggesting that behavioral and network signals
-- may be stronger predictors.
-- =============================================

-- Do fraudulent transactions have higher IP risk scores than legitimate ones?
SELECT ROUND(AVG(ip_risk_score),2) AS ip_avg, t.is_fraud, 
		COUNT(*) AS total_transactions
FROM transactions AS t
GROUP BY t.is_fraud
ORDER BY ip_avg;

-- INSIGHT:
-- Yes, fraudulent transactions have a higher average IP risk score (46.25)
-- compared to legitimate ones (39.24), a difference of 7 points.
-- This suggests IP risk score is a meaningful fraud signal, unlike the
-- categorical variables tested earlier which showed less than 1% spread.

