-- ==========================================
-- 📊 View: ecom_retailer_03_segment_returns.session.sql
-- 📌 Purpose:
--     - Analyze return behavior across customer segments:
--         • Loyalty tier
--         • CLV bucket
--         • Guest/account status
--         • Signup channel
-- ==========================================

-- ==========================================
-- 📊 View: customer_segment_sales_returns
-- 📌 Purpose: Guest vs account return behavior over time
-- ==========================================
DROP VIEW IF EXISTS customer_segment_sales_returns;
CREATE VIEW customer_segment_sales_returns AS
-- monthly sales by guest status
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    c.is_guest,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
  LEFT JOIN cleaned_customers c ON o.customer_id = c.customer_id
),
-- returns aggregated by order
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and guest status
SELECT 
  ob.month,
  COALESCE(ob.is_guest, 'unknown') AS is_guest,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, is_guest
ORDER BY ob.month, is_guest;


-- 📊 View: monthly_channel_sales_returns
-- 📌 Purpose: Return performance by order channel per month
-- ==========================================
DROP VIEW IF EXISTS monthly_channel_sales_returns;
CREATE VIEW monthly_channel_sales_returns AS
-- return metrics by order channel
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COALESCE(NULLIF(TRIM(o.order_channel), ''), 'unknown') AS order_channel,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
),
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and order channel
SELECT 
  ob.month,
  ob.order_channel,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, ob.order_channel
ORDER BY ob.month, ob.order_channel;

-- ==========================================

-- ==========================================
-- 📊 View: monthly_loyalty_sales_returns
-- 📌 Purpose: Monthly sales and return performance by loyalty tier
-- ==========================================
DROP VIEW IF EXISTS monthly_loyalty_sales_returns;
CREATE VIEW monthly_loyalty_sales_returns AS
-- return metrics by loyalty tier
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COALESCE(NULLIF(TRIM(c.loyalty_tier), ''), 'unknown') AS loyalty_tier,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
  LEFT JOIN cleaned_customers c ON o.customer_id = c.customer_id
),
-- returns aggregated by order
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and loyalty tier
SELECT 
  ob.month,
  ob.loyalty_tier,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, ob.loyalty_tier
ORDER BY ob.month, ob.loyalty_tier;

-- ==========================================
-- 📊 View: monthly_signup_channel_sales_returns
-- 📌 Purpose: Return behavior by signup channel over time
-- ==========================================
DROP VIEW IF EXISTS monthly_signup_channel_sales_returns;
CREATE VIEW monthly_signup_channel_sales_returns AS
-- sales and returns by signup channel
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COALESCE(NULLIF(TRIM(c.signup_channel), ''), 'unknown') AS signup_channel,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
  LEFT JOIN cleaned_customers c ON o.customer_id = c.customer_id
),
-- returns aggregated by order
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and signup channel
SELECT 
  ob.month,
  ob.signup_channel,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, ob.signup_channel
ORDER BY ob.month, ob.signup_channel;

-- ==========================================
-- 📊 View: monthly_clv_sales_returns
-- 📌 Purpose: Monthly sales and return performance by CLV bucket
-- ==========================================
DROP VIEW IF EXISTS monthly_clv_sales_returns;
CREATE VIEW monthly_clv_sales_returns AS
-- return metrics by CLV bucket
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COALESCE(NULLIF(TRIM(c.clv_bucket), ''), 'unknown') AS clv_bucket,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
  LEFT JOIN cleaned_customers c ON o.customer_id = c.customer_id
),
-- returns aggregated by order
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and CLV bucket
SELECT 
  ob.month,
  ob.clv_bucket,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, ob.clv_bucket
ORDER BY ob.month, ob.clv_bucket;

-- ==========================================
-- 📊 View: top_customers_by_returns
-- 📌 Purpose: Identify top 25 customers by refunded value and return rate
-- ==========================================
DROP VIEW IF EXISTS top_customers_by_returns;
CREATE VIEW top_customers_by_returns AS
-- top 25 customers by refunded value
WITH customer_sales AS (
  SELECT 
    o.customer_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(o.order_total), 2) AS total_sales,
    MIN(strftime('%Y-%m', o.order_date)) AS first_order_month
  FROM cleaned_orders o
  GROUP BY o.customer_id
),
customer_returns AS (
  SELECT 
    r.customer_id,
    COUNT(DISTINCT r.return_id) AS total_returns,
    ROUND(SUM(r.refunded_amount), 2) AS total_refunded,
    ROUND(AVG(r.refunded_amount), 2) AS avg_return_value,
    MAX(strftime('%Y-%m', r.return_date)) AS last_return_month
  FROM cleaned_returns r
  GROUP BY r.customer_id
)
-- join customer sales, returns, and profile data
SELECT 
  r.customer_id,
  c.email,
  COALESCE(NULLIF(TRIM(c.clv_bucket), ''), 'unknown') AS clv_bucket,
  COALESCE(NULLIF(TRIM(c.loyalty_tier), ''), 'unknown') AS loyalty_tier,
  COALESCE(c.is_guest, 'unknown') AS is_guest,
  COALESCE(NULLIF(TRIM(c.signup_channel), ''), 'unknown') AS signup_channel,
  s.total_orders,
  s.total_sales,
  r.total_returns,
  r.total_refunded,
  r.avg_return_value,
  ROUND(100.0 * r.total_refunded / NULLIF(s.total_sales, 0), 2) AS return_rate,
  s.first_order_month,
  r.last_return_month
FROM customer_returns r
LEFT JOIN customer_sales s ON r.customer_id = s.customer_id
LEFT JOIN cleaned_customers c ON r.customer_id = c.customer_id
ORDER BY r.total_refunded DESC
LIMIT 25;

-- ==========================================
-- 📊 View: monthly_payment_sales_returns
-- 📌 Purpose: Monthly sales and return performance by payment method
-- ==========================================
DROP VIEW IF EXISTS monthly_payment_sales_returns;
CREATE VIEW monthly_payment_sales_returns AS
-- return metrics by payment method
WITH order_base AS (
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    COALESCE(NULLIF(TRIM(o.payment_method), ''), 'unknown') AS payment_method,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
),
-- returns aggregated by order
returns_base AS (
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  GROUP BY r.order_id
)
-- aggregate sales and returns by month and payment method
SELECT 
  ob.month,
  ob.payment_method,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.month, ob.payment_method
ORDER BY ob.month, ob.payment_method;

-- ==========================================
-- ✅ Summary:
--     - Segmented sales and returns by customer attributes
--     - Included CLV bucket, loyalty tier, guest status, and signup channel
--     - Highlighted top 25 customers by refunded value
--     - Re-added monthly sales/returns breakdown by CLV bucket
-- ==========================================

-- ==========================================
-- 📅 Finalized on: 07/17/25
-- 🧑‍💻 Author: Garrett Schumacher
-- ==========================================