-- ==============================================
-- 📍 File: ecom_retailer_02_core_metrics.session.sql
-- 📌 Purpose:
--     - Define core metrics and monthly sales/returns views
--     - Support return rate analysis, product trends, and segmentation
-- ==============================================


-- ==========================================
-- 📊 View: category_monthly_sales_returns
-- 📌 Purpose: Monthly sales and return breakdown by product category
-- ==========================================
DROP VIEW IF EXISTS category_monthly_sales_returns;

CREATE VIEW category_monthly_sales_returns AS
WITH order_enriched AS (
  -- order details with category and sales
  SELECT 
    o.order_id,
    oi.product_id,
    LOWER(TRIM(pc.category)) AS product_category,
    o.order_date,
    oi.unit_price * oi.quantity AS sales_amount,
    strftime('%Y-%m', o.order_date) AS month,
    strftime('%Y', o.order_date) AS year
  FROM cleaned_orders o
  JOIN cleaned_order_items oi ON o.order_id = oi.order_id
  LEFT JOIN cleaned_product_catalog pc ON oi.product_id = pc.product_id
  WHERE DATE(o.order_date) BETWEEN '2024-07-19' AND '2025-07-19'
),
return_enriched AS (
  -- return details with category and refund
  SELECT 
    r.return_id,
    ri.product_id,
    LOWER(TRIM(pc.category)) AS product_category,
    r.return_date,
    ri.refunded_amount AS refund_amount,
    strftime('%Y-%m', r.return_date) AS month,
    strftime('%Y', r.return_date) AS year
  FROM cleaned_returns r
  JOIN cleaned_return_items ri ON r.return_id = ri.return_id
  LEFT JOIN cleaned_product_catalog pc ON ri.product_id = pc.product_id
  WHERE DATE(r.return_date) BETWEEN '2024-07-19' AND '2025-07-19'
)
SELECT 
  product_category,
  year,
  month,
  ROUND(SUM(total_sales), 2) AS total_sales,
  ROUND(SUM(total_returns), 2) AS total_returns,
  ROUND(
    100.0 * SUM(total_returns) / NULLIF(SUM(total_sales), 0), 
    2
  ) AS percent_revenue_lost
FROM (
  SELECT 
    product_category,
    year,
    month,
    SUM(sales_amount) AS total_sales,
    0 AS total_returns
  FROM order_enriched
  GROUP BY product_category, year, month

  UNION ALL

  SELECT 
    product_category,
    year,
    month,
    0 AS total_sales,
    SUM(refund_amount) AS total_returns
  FROM return_enriched
  GROUP BY product_category, year, month
) AS combined
GROUP BY product_category, year, month
ORDER BY product_category, year, month;


-- ==========================================
-- 📊 View: monthly_sales_returns_summary
-- 📌 Purpose: Overview of total sales, returns, and % revenue refunded
-- ==========================================
DROP VIEW IF EXISTS monthly_sales_returns_summary;
CREATE VIEW monthly_sales_returns_summary AS
WITH monthly_orders AS (
  -- monthly order totals and sales
  SELECT 
    strftime('%Y-%m', order_date) AS month,
    strftime('%Y', order_date) AS year,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(order_total), 2) AS total_sales
  FROM cleaned_orders
  WHERE order_date BETWEEN '2024-07-19' AND '2025-07-19'
  GROUP BY year, month
),
monthly_returns AS (
  -- monthly return totals
  SELECT 
    strftime('%Y-%m', return_date) AS month,
    strftime('%Y', return_date) AS year,
    COUNT(DISTINCT return_id) AS total_returns,
    ROUND(SUM(refunded_amount), 2) AS total_refunds
  FROM cleaned_returns
  WHERE return_date BETWEEN '2024-07-19' AND '2025-07-19'
  GROUP BY year, month
)
SELECT 
  o.year,
  o.month,
  o.total_orders,
  r.total_returns,
  o.total_sales,
  r.total_refunds,
  ROUND(100.0 * r.total_refunds / NULLIF(o.total_sales, 0), 2) AS percent_revenue_returned
FROM monthly_orders o
LEFT JOIN monthly_returns r ON o.year = r.year AND o.month = r.month
ORDER BY o.year, o.month;

-- ==========================================
-- 📊 View: monthly_channel_sales_returns
-- 📌 Purpose: Return performance by order channel per month
-- ==========================================
DROP VIEW IF EXISTS monthly_channel_sales_returns;
CREATE VIEW monthly_channel_sales_returns AS
WITH order_base AS (
  -- channel breakdown by month
  SELECT 
    strftime('%Y-%m', order_date) AS month,
    strftime('%Y', order_date) AS year,
    LOWER(TRIM(order_channel)) AS order_channel,
    order_id,
    order_total
  FROM cleaned_orders
  WHERE order_date BETWEEN '2024-07-19' AND '2025-07-19'
),
returns_base AS (
  -- return totals by order
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    strftime('%Y', r.return_date) AS year,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  WHERE r.return_date BETWEEN '2024-07-19' AND '2025-07-19'
  GROUP BY r.order_id, year, month
)
SELECT 
  o.year,
  o.month,
  o.order_channel,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(o.order_total), 2) AS total_sales,
  COUNT(DISTINCT r.order_id) AS total_returns,
  ROUND(SUM(COALESCE(r.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(r.total_refund, 0)) / NULLIF(SUM(o.order_total), 0), 2) AS percent_revenue_returned
FROM order_base o
LEFT JOIN returns_base r ON o.order_id = r.order_id
GROUP BY o.year, o.month, o.order_channel
ORDER BY o.year, o.month, o.order_channel;

-- ==========================================
-- 📊 View: customer_segment_sales_returns
-- 📌 Purpose: Guest vs account return behavior over time
-- ==========================================
DROP VIEW IF EXISTS customer_segment_sales_returns;
CREATE VIEW customer_segment_sales_returns AS
WITH order_base AS (
  -- guest vs account return rates
  SELECT 
    strftime('%Y-%m', o.order_date) AS month,
    strftime('%Y', o.order_date) AS year,
    c.is_guest,
    o.order_id,
    o.order_total
  FROM cleaned_orders o
  LEFT JOIN cleaned_customers c ON o.customer_id = c.customer_id
  WHERE o.order_date BETWEEN '2024-07-19' AND '2025-07-19'
),
returns_base AS (
  -- return totals by order
  SELECT 
    r.order_id,
    strftime('%Y-%m', r.return_date) AS month,
    strftime('%Y', r.return_date) AS year,
    SUM(r.refunded_amount) AS total_refund
  FROM cleaned_returns r
  WHERE r.return_date BETWEEN '2024-07-19' AND '2025-07-19'
  GROUP BY r.order_id, year, month
)
SELECT 
  ob.year,
  ob.month,
  COALESCE(ob.is_guest, 'unknown') AS is_guest,
  COUNT(DISTINCT ob.order_id) AS total_orders,
  ROUND(SUM(ob.order_total), 2) AS total_sales,
  COUNT(DISTINCT rb.order_id) AS total_returns,
  ROUND(SUM(COALESCE(rb.total_refund, 0)), 2) AS total_refunds,
  ROUND(100.0 * SUM(COALESCE(rb.total_refund, 0)) / NULLIF(SUM(ob.order_total), 0), 2) AS percent_revenue_returned
FROM order_base ob
LEFT JOIN returns_base rb ON ob.order_id = rb.order_id
GROUP BY ob.year, ob.month, is_guest
ORDER BY ob.year, ob.month, is_guest;


-- ==========================================
-- 📊 View: return_reason_summary
-- 📌 Purpose: Count and refund summary by return reason
-- ==========================================
DROP VIEW IF EXISTS return_reason_summary;
CREATE VIEW return_reason_summary AS
WITH ranked_returns AS (
  SELECT
    LOWER(TRIM(reason)) AS normalized_reason,
    refunded_amount,
    ROW_NUMBER() OVER (PARTITION BY LOWER(TRIM(reason)) ORDER BY refunded_amount) AS rn,
    COUNT(*) OVER (PARTITION BY LOWER(TRIM(reason))) AS cnt
  FROM cleaned_returns
  WHERE return_date BETWEEN '2024-07-19' AND '2025-07-19'
),
median_returns AS (
  SELECT
    normalized_reason,
    refunded_amount AS median_refund_per_return
  FROM ranked_returns rr1
  WHERE rr1.rn IN (
    (rr1.cnt + 1) / 2,
    (rr1.cnt + 2) / 2
  )
)
SELECT
  normalized_reason,
  COUNT(*) AS total_returns,
  ROUND(SUM(refunded_amount), 2) AS total_refunded,
  ROUND(AVG(refunded_amount), 2) AS avg_refund_per_return,
  ROUND(AVG(mr.median_refund_per_return), 2) AS median_refund_per_return
FROM cleaned_returns rr
JOIN (
  SELECT normalized_reason, AVG(median_refund_per_return) AS median_refund_per_return
  FROM median_returns
  GROUP BY normalized_reason
) mr ON LOWER(TRIM(rr.reason)) = mr.normalized_reason
WHERE rr.return_date BETWEEN '2024-07-19' AND '2025-07-19'
GROUP BY normalized_reason
ORDER BY total_returns DESC;

-- ==========================================
-- 📊 View: return_rate_by_product
-- 📌 Purpose: Return rate % by product with return reason and refund summary
-- ==========================================
DROP VIEW IF EXISTS return_rate_by_product;
CREATE VIEW return_rate_by_product AS
WITH product_orders AS (
  -- product order counts with category
  SELECT
    oi.product_id,
    COALESCE(LOWER(TRIM(pc.product_name)), LOWER(TRIM(oi.product_name)), 'unknown') AS product_name,
    COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
    COUNT(*) AS order_count
  FROM cleaned_order_items oi
  LEFT JOIN cleaned_product_catalog pc ON oi.product_id = pc.product_id
  GROUP BY 1, 2, 3
),
product_returns AS (
  -- product return counts with category and reason
  SELECT
    ri.product_id,
    COALESCE(LOWER(TRIM(pc.product_name)), LOWER(TRIM(ri.product_name)), 'unknown') AS product_name,
    COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
    LOWER(TRIM(r.reason)) AS return_reason,
    COUNT(*) AS return_count,
    ROUND(SUM(ri.refunded_amount), 2) AS total_refunded,
    ROUND(AVG(ri.refunded_amount), 2) AS avg_refund
  FROM cleaned_return_items ri
  JOIN cleaned_returns r ON ri.return_id = r.return_id
  LEFT JOIN cleaned_product_catalog pc ON ri.product_id = pc.product_id
  GROUP BY 1, 2, 3, 4
)
SELECT
  po.product_id,
  po.product_name,
  pr.return_reason,
  po.product_category,
  po.order_count,
  COALESCE(pr.return_count, 0) AS return_count,
  COALESCE(pr.total_refunded, 0) AS total_refunded,
  COALESCE(pr.avg_refund, 0) AS avg_refund,
  ROUND(100.0 * COALESCE(pr.return_count, 0) / NULLIF(po.order_count, 0), 2) AS return_rate_percent
FROM product_orders po
LEFT JOIN product_returns pr ON po.product_id = pr.product_id
ORDER BY po.product_category, return_rate_percent DESC;

-- ==========================================
-- ✅ Summary:
--     - Defined core metrics for monthly sales vs returns
--     - Created category, channel, guest, and product-level breakdowns
--     - Included return reasons and return rate by product
-- ==========================================

-- ==========================================
-- ✅ Session Complete: ecom_retailer_02_core_metrics.session.sql
-- 📅 Finalized on: 07/17/25
-- 🧑‍💻 Author: Garrett Schumacher
-- ==========================================