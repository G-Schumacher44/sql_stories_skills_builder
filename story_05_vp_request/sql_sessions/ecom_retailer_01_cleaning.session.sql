-- ==============================================
-- 📍 File: ecom_retailer_01_cleaning.session.sql
-- 📌 Purpose:
--     - Normalize and clean base tables (returns, return items, catalog, customers, orders, order items)
--     - Apply text standardization, deduplication, and refund sanity checks
-- ==============================================


-- count $0 refunds (returns)
SELECT COUNT(*) AS zero_dollar_returns
FROM returns
WHERE refunded_amount = 0;

-- count $0 refunds (return items)
SELECT COUNT(*) AS zero_dollar_return_items
FROM return_items
WHERE refunded_amount = 0;

-- ==========================================
-- 📊 View: cleaned_returns
-- 📌 Purpose: Normalize return reason text, exclude zero-dollar and duplicate records
-- ==========================================
DROP VIEW IF EXISTS cleaned_returns;
CREATE VIEW cleaned_returns AS
SELECT 
  MIN(return_id) AS return_id, -- preserve one row per normalized reason
  order_id,
  customer_id,
  LOWER(TRIM(reason)) AS reason,
  DATE(return_date) AS return_date,
  refunded_amount
FROM returns
WHERE TRIM(reason) != '' AND reason IS NOT NULL
  AND refunded_amount > 0
GROUP BY LOWER(TRIM(reason)), order_id, customer_id, DATE(return_date), refunded_amount;

-- ==========================================
-- 📊 View: cleaned_return_items
-- 📌 Purpose: Filter out zero-dollar return items and standardize text fields
-- ==========================================
DROP VIEW IF EXISTS cleaned_return_items;
CREATE VIEW cleaned_return_items AS
SELECT DISTINCT
  return_id,
  product_id,
  LOWER(TRIM(product_name)) AS product_name,
  refunded_amount
FROM return_items
WHERE refunded_amount > 0;

-- ==========================================
-- 📊 View: cleaned_product_catalog
-- 📌 Purpose: Normalize product name/category, deduplicate catalog entries
-- ==========================================
DROP VIEW IF EXISTS cleaned_product_catalog;
CREATE VIEW cleaned_product_catalog AS
SELECT 
  MIN(product_id) AS product_id, -- preserve one row per normalized product
  LOWER(TRIM(product_name)) AS product_name,
  LOWER(TRIM(category)) AS category,
  unit_price
FROM product_catalog
WHERE TRIM(product_name) != '' AND product_name IS NOT NULL
GROUP BY LOWER(TRIM(product_name)), LOWER(TRIM(category)), unit_price;

-- ==========================================
-- 📊 View: cleaned_customers
-- 📌 Purpose: Standardize customer demographic fields and null handling
-- ==========================================
DROP VIEW IF EXISTS cleaned_customers;
CREATE VIEW cleaned_customers AS
SELECT
  customer_id,
  COALESCE(NULLIF(LOWER(TRIM(loyalty_tier)), ''), 'unknown') AS loyalty_tier,
  COALESCE(NULLIF(LOWER(TRIM(clv_bucket)), ''), 'unknown') AS clv_bucket,
  COALESCE(NULLIF(LOWER(TRIM(signup_channel)), ''), 'unknown') AS signup_channel,
  COALESCE(NULLIF(LOWER(TRIM(gender)), ''), 'unknown') AS gender,
  COALESCE(NULLIF(LOWER(TRIM(customer_status)), ''), 'unknown') AS customer_status,
  TRIM(LOWER(mailing_address)) AS mailing_address,
  TRIM(LOWER(billing_address)) AS billing_address,
  DATE(signup_date) AS signup_date,
  DATE(loyalty_enrollment_date) AS loyalty_enrollment_date,
  email,
  COALESCE(NULLIF(TRIM(email_verified), ''), 'unknown') AS email_verified,
  COALESCE(marketing_opt_in, FALSE) AS marketing_opt_in,
  age,
  is_guest
FROM customers;

-- ==========================================
-- 📊 View: cleaned_orders
-- 📌 Purpose: Cleanse order records and normalize categorical fields
-- ==========================================
DROP VIEW IF EXISTS cleaned_orders;
CREATE VIEW cleaned_orders AS
SELECT
  order_id,
  customer_id,
  email,
  DATE(order_date) AS order_date,
  LOWER(TRIM(order_channel)) AS order_channel,
  LOWER(TRIM(payment_method)) AS payment_method,
  LOWER(TRIM(shipping_speed)) AS shipping_speed,
  is_expedited,
  agent_id,
  shipping_address,
  billing_address,
  order_total,
  total_items,
  COALESCE(NULLIF(LOWER(TRIM(clv_bucket)), ''), 'unknown') AS clv_bucket
FROM orders;

-- ==========================================
-- 📊 View: cleaned_order_items
-- 📌 Purpose: Normalize item fields and remove zero quantity or price entries
-- ==========================================
DROP VIEW IF EXISTS cleaned_order_items;
CREATE VIEW cleaned_order_items AS
SELECT DISTINCT
  order_id,
  product_id,
  LOWER(TRIM(product_name)) AS product_name,
  LOWER(TRIM(category)) AS category,
  quantity,
  unit_price
FROM order_items
WHERE quantity > 0 AND unit_price > 0;

-- ==========================================
-- 🔍 sanity checks: deduplication and text normalization
-- ==========================================

-- check duplicate return_ids in cleaned_returns
SELECT return_id, COUNT(*) AS count
FROM cleaned_returns
GROUP BY return_id
HAVING COUNT(*) > 1;

-- check duplicate return_id/product_id pairs in cleaned_return_items
SELECT return_id, product_id, COUNT(*) AS count
FROM cleaned_return_items
GROUP BY return_id, product_id
HAVING COUNT(*) > 1;

-- find fuzzy product name dupes
SELECT 
  LOWER(TRIM(product_name)) AS normalized_name,
  COUNT(*) AS count,
  GROUP_CONCAT(DISTINCT product_name) AS variants
FROM product_catalog
GROUP BY normalized_name
HAVING COUNT(*) > 1
ORDER BY count DESC;

-- find fuzzy return reason dupes
SELECT 
  LOWER(TRIM(reason)) AS normalized_reason,
  COUNT(*) AS count,
  GROUP_CONCAT(DISTINCT reason) AS variants
FROM returns
GROUP BY normalized_reason
HAVING COUNT(*) > 1
ORDER BY count DESC;


SELECT DISTINCT 
  original.reason AS raw_reason,
  cleaned.reason AS normalized_reason
FROM returns AS original
JOIN cleaned_returns AS cleaned 
  ON original.return_id = cleaned.return_id
ORDER BY raw_reason;

-- ==========================================
-- ✅ Summary:
--     - Normalized returns, return items, and product catalog
--     - Cleaned customer, order, and order item tables
--     - Applied text trimming, lowercasing, and value normalization
--     - Added sanity checks for refund amounts and fuzzy duplicates
-- ==========================================

-- ==========================================
-- 📅 finalized on: 07/17/25
-- 🧑‍💻 author: Garrett Schumacher
-- ==========================================