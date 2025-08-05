-- ==========================================
-- 📍 File: ecom_retailer_04_logistics_summary.session.sql
-- 📌 Purpose:
--     - Regional return and sales analysis by address pattern
--     - Return impact breakdown by shipping speed
-- ==========================================

-- ==========================================
-- 📊 View: region_summary_by_state
-- 📌 Purpose: Regional returns and revenue impact by inferred state code
-- ==========================================
DROP VIEW IF EXISTS region_summary_by_state;

CREATE VIEW region_summary_by_state AS
WITH address_cleaned AS (
  -- extract billing state substring
  SELECT
    customer_id,
    LOWER(TRIM(SUBSTR(billing_address, -8, 2))) AS state_code
  FROM cleaned_customers
  WHERE billing_address IS NOT NULL
),
orders_with_region AS (
  -- aggregate monthly orders by state
  SELECT
    o.order_id,
    strftime('%Y-%m', o.order_date) AS order_month,
    o.order_total,
    ac.state_code
  FROM cleaned_orders o
  LEFT JOIN address_cleaned ac ON o.customer_id = ac.customer_id
),
returns_with_region AS (
  SELECT
    strftime('%Y-%m', o.order_date) AS order_month,
    ac.state_code,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(SUM(r.refunded_amount), 2) AS total_refunded
  FROM cleaned_returns r
  JOIN cleaned_orders o ON r.order_id = o.order_id
  LEFT JOIN address_cleaned ac ON r.customer_id = ac.customer_id
  GROUP BY ac.state_code, order_month
)
-- join orders with returns by state and month
SELECT
  CASE
    WHEN UPPER(ow.state_code) IN ('CT', 'ME', 'MA', 'NH', 'RI', 'VT', 'NJ', 'NY', 'PA') THEN 'Northeast'
    WHEN UPPER(ow.state_code) IN ('IL', 'IN', 'MI', 'OH', 'WI', 'IA', 'KS', 'MN', 'MO', 'NE', 'ND', 'SD') THEN 'Midwest'
    WHEN UPPER(ow.state_code) IN ('DE', 'FL', 'GA', 'MD', 'NC', 'SC', 'VA', 'DC', 'AL', 'KY', 'MS', 'TN', 'AR', 'LA', 'OK', 'TX', 'WV') THEN 'South'
    WHEN UPPER(ow.state_code) IN ('AZ', 'CO', 'ID', 'MT', 'NV', 'NM', 'UT', 'WY', 'AK', 'CA', 'HI', 'OR', 'WA') THEN 'West'
    WHEN UPPER(ow.state_code) IN ('PR', 'VI', 'GU', 'MP', 'AS') THEN 'Territory'
    WHEN UPPER(ow.state_code) IN ('AA', 'AE', 'AP') THEN 'Military'
    ELSE 'Unknown'
  END AS region,
  ow.state_code,
  ow.order_month,
  COUNT(DISTINCT ow.order_id) AS total_orders,
  ROUND(SUM(ow.order_total), 2) AS total_sales,
  COALESCE(rw.total_returns, 0) AS total_returns,
  COALESCE(rw.total_refunded, 0) AS total_refunds,
  ROUND(100.0 * COALESCE(rw.total_refunded, 0) / NULLIF(SUM(ow.order_total), 0), 2) AS percent_revenue_refunded
FROM orders_with_region ow
LEFT JOIN returns_with_region rw
  ON ow.state_code = rw.state_code AND ow.order_month = rw.order_month
GROUP BY region, ow.state_code, ow.order_month
ORDER BY region, ow.state_code, ow.order_month;




-- ==========================================
-- 📊 View: shipping_return_impact_summary
-- 📌 Purpose: Return rate and refund percentage by shipping speed and month
-- ==========================================

DROP VIEW IF EXISTS shipping_return_impact_summary;

CREATE VIEW shipping_return_impact_summary AS
WITH order_metrics AS (
  SELECT
    order_id,
    shipping_speed,
    order_total,
    strftime('%Y-%m', order_date) AS order_month
  FROM cleaned_orders
),
return_metrics AS (
  SELECT
    order_id,
    return_id,
    refunded_amount
  FROM cleaned_returns
)
SELECT
  om.shipping_speed,
  om.order_month,
  COUNT(DISTINCT om.order_id) AS total_orders,
  COUNT(DISTINCT rm.return_id) AS total_returns,
  ROUND(SUM(rm.refunded_amount), 2) AS total_refunded,
  ROUND(100.0 * COUNT(DISTINCT rm.return_id) / NULLIF(COUNT(DISTINCT om.order_id), 0), 2) AS return_rate_pct,
  ROUND(100.0 * SUM(rm.refunded_amount) / NULLIF(SUM(om.order_total), 0), 2) AS revenue_refunded_pct
FROM order_metrics om
LEFT JOIN return_metrics rm ON om.order_id = rm.order_id
GROUP BY om.shipping_speed, om.order_month
ORDER BY om.shipping_speed, om.order_month;


-- ==========================================
-- 📊 View: logistics_return_impact_summary
-- 📌 Purpose: Return rates and refund impact segmented by expedited flag and shipping tier
-- ==========================================

DROP VIEW IF EXISTS logistics_return_impact_summary;

CREATE VIEW logistics_return_impact_summary AS
WITH orders_logistics AS (
  SELECT
    order_id,
    customer_id,
    shipping_speed,
    is_expedited,
    order_total,
    strftime('%Y-%m', order_date) AS order_month
  FROM cleaned_orders
),
returns_logistics AS (
  SELECT
    r.return_id,
    r.order_id,
    r.refunded_amount,
    strftime('%Y-%m', r.return_date) AS return_month
  FROM cleaned_returns r
)
SELECT
  ol.shipping_speed,
  ol.is_expedited,
  ol.order_month,
  COUNT(DISTINCT ol.order_id) AS total_orders,
  COUNT(DISTINCT rl.return_id) AS total_returns,
  ROUND(SUM(rl.refunded_amount), 2) AS total_refunded,
  ROUND(100.0 * COUNT(DISTINCT rl.return_id) / NULLIF(COUNT(DISTINCT ol.order_id), 0), 2) AS return_rate_pct,
  ROUND(100.0 * SUM(rl.refunded_amount) / NULLIF(SUM(ol.order_total), 0), 2) AS revenue_refunded_pct
FROM orders_logistics ol
LEFT JOIN returns_logistics rl ON ol.order_id = rl.order_id
GROUP BY ol.shipping_speed, ol.is_expedited, ol.order_month
ORDER BY ol.shipping_speed, ol.is_expedited, ol.order_month;

-- ==========================================
-- ✅ Summary:
--     - Regional returns and revenue impact by inferred state code
--     - Return rate and refund percentage by shipping speed and month
--     - Added logistics-return summary view segmented by expedited flag and shipping tier
-- ==========================================

-- ==========================================
-- 📅 Finalized on: 07/17/25
-- 🧑‍💻 Author: Garrett Schumacher
-- ==========================================