-- ==========================================
-- 📊 ECOM DASHBOARD VIEWS: STORY 01
-- ==========================================
-- 📝 This file contains views prepared specifically for use in dashboard tools (e.g. Looker Studio)
--     - Derived from the validated exploratory notebook: Q3_sales_returns_diagnostic_analysis.ipynb
--     - All logic here should be SQL-safe and dashboard-compatible (no nested CTEs where not needed)
--     - Focused on product-level return patterns and quality-related risk flags

-- ⚠️ Assumes cleaned base tables exist:
--     cleaned_orders, cleaned_order_items, cleaned_returns, cleaned_return_items, cleaned_product_catalog

-- ==========================================
-- 🔧 VIEW 1: return_reason_quality_flags
-- 📌 Purpose: Flag and classify return reasons for downstream filtering and aggregation
-- 📋 Assumptions:
--     - Return reasons are cleaned and meaningful after trimming and lowercasing
--     - Quality-related reasons are predefined as those indicating product faults or damage
-- 🗂️ Fields:
--     - normalized_reason: cleaned, lowercase return reason text
--     - is_quality_reason: binary flag (1 = quality-related reason, 0 = otherwise)
-- 🧠 Reasoning:
--     - Enables filtering and aggregation of returns by quality issue status
--     - Helps isolate problematic product return causes for risk assessment
-- ==========================================
DROP VIEW IF EXISTS dash_return_reason_quality_flags;
CREATE VIEW dash_return_reason_quality_flags AS
SELECT
  LOWER(TRIM(reason)) AS normalized_reason,
  CASE
    WHEN LOWER(TRIM(reason)) IN (
      'defective',
      'arrived damaged',
      'product did not match description',
      'damaged in transit',
      'missing parts'
    ) THEN 1
    ELSE 0
  END AS is_quality_reason
FROM (
  SELECT DISTINCT reason
  FROM cleaned_returns
  WHERE reason IS NOT NULL AND TRIM(reason) != ''
);

-- ==========================================
-- 🔧 VIEW 2: product_quality_risk_summary
-- 📌 Purpose: Aggregate return behavior per product with quality dominance metrics
-- 📋 Assumptions:
--     - Product names and categories may be missing; use 'unknown' as fallback
--     - Return reasons are linked to quality flags via return_reason_quality_flags view
--     - Refunded amounts reflect monetary impact of returns
-- 🗂️ Fields:
--     - product_id, product_name, product_category: product identifiers and descriptors
--     - order_count: total number of orders for the product
--     - total_returns: total return count for the product
--     - total_refunded: total refunded amount associated with returns
--     - quality_returns: count of returns flagged as quality-related
--     - quality_return_pct: percentage of returns related to quality issues
--     - quality_risk_tier: categorical risk tier based on quality return ratio
-- 🧠 Reasoning:
--     - Combines order and return data to identify products with high quality return rates
--     - Risk tiers provide actionable insights for prioritizing product quality investigations
-- ==========================================
DROP VIEW IF EXISTS dash_product_quality_risk_summary;
CREATE VIEW dash_product_quality_risk_summary AS
WITH order_counts AS (
  SELECT
    oi.product_id,
    COALESCE(LOWER(TRIM(pc.product_name)), LOWER(TRIM(oi.product_name)), 'unknown') AS product_name,
    COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
    COUNT(*) AS order_count
  FROM cleaned_order_items oi
  LEFT JOIN cleaned_product_catalog pc ON oi.product_id = pc.product_id
  GROUP BY 1, 2, 3
),
return_reasons AS (
  SELECT
    ri.product_id,
    COALESCE(LOWER(TRIM(pc.product_name)), LOWER(TRIM(ri.product_name)), 'unknown') AS product_name,
    LOWER(TRIM(r.reason)) AS return_reason,
    COUNT(*) AS return_count,
    SUM(ri.refunded_amount) AS total_refunded
  FROM cleaned_return_items ri
  JOIN cleaned_returns r ON ri.return_id = r.return_id
  LEFT JOIN cleaned_product_catalog pc ON ri.product_id = pc.product_id
  GROUP BY 1, 2, 3
),
reason_flags AS (
  SELECT * FROM dash_return_reason_quality_flags
),
flagged_returns AS (
  SELECT
    rr.product_id,
    rr.product_name,
    rr.return_reason,
    rr.return_count,
    rr.total_refunded,
    rf.is_quality_reason
  FROM return_reasons rr
  LEFT JOIN reason_flags rf ON rr.return_reason = rf.normalized_reason
),
product_agg AS (
  SELECT
    fr.product_id,
    fr.product_name,
    SUM(fr.return_count) AS total_returns,
    SUM(fr.total_refunded) AS total_refunded,
    SUM(CASE WHEN fr.is_quality_reason = 1 THEN fr.return_count ELSE 0 END) AS quality_returns
  FROM flagged_returns fr
  GROUP BY fr.product_id, fr.product_name
)
SELECT
  oc.product_id,
  oc.product_name,
  oc.product_category,
  oc.order_count,
  pa.total_returns,
  pa.total_refunded,
  pa.quality_returns,
  ROUND(100.0 * pa.quality_returns / NULLIF(pa.total_returns, 0), 2) AS quality_return_pct,
  CASE
    WHEN ROUND(1.0 * pa.quality_returns / NULLIF(pa.total_returns, 0), 2) > 0.5 THEN '⛔️ High Risk'
    WHEN ROUND(1.0 * pa.quality_returns / NULLIF(pa.total_returns, 0), 2) > 0.33 THEN '⚠️ Moderate Risk'
    ELSE '🟢 Low Risk'
  END AS quality_risk_tier
FROM product_agg pa
JOIN order_counts oc ON pa.product_id = oc.product_id;

-- ==========================================
-- 🧪 NOTES FOR DEBUGGING AND MAINTENANCE
-- ==========================================
-- 🧩 CLEANED TABLE DEPENDENCIES:
--     - All joins rely on cleaned_return_items + cleaned_returns for reason/amount
--     - Product names are normalized via COALESCE and LOWER(TRIM())
-- 🧠 QUALITY DEFINITION LOGIC:
--     - Defined via a fixed list of reasons in view 1
--     - Can be extended via an external lookup or config table in the future
-- ⚙️ FUTURE EXTENSIONS:
--     - Add return_rate_percent (total_returns / order_count)
--     - Join customer segments or time windows if needed
--     - Generate monthly trends from this core view

-- ✅ Ready for dashboard connection
--     - All columns are final and human-readable
--     - Use `quality_risk_tier` or `quality_return_pct` in filters and tooltips


-- ==========================================
-- 🔧 VIEW 3: dash_monthly_sales_refunds
-- 📌 Purpose: Track monthly sales, refunds, and the refund rate over time.
-- 📋 Assumptions:
--     - `cleaned_orders` contains all sales with `order_date` and `order_total`.
--     - `cleaned_returns` contains all refunds with `refunded_amount` and can be linked back to an order.
--     - Pre-aggregating sales and refunds separately prevents fan-out issues.
-- 🗂️ Fields:
--     - month: The month of the activity (YYYY-MM format).
--     - total_sales: Total gross sales for the month.
--     - total_refunds: Total amount refunded for the month.
--     - refund_rate_pct: The percentage of sales that were refunded.
-- 🧠 Reasoning:
--     - Provides a high-level overview of business health and trends in customer returns.
--     - Essential for financial planning and identifying seasonal patterns in sales and returns.
-- ==========================================
DROP VIEW IF EXISTS dash_monthly_sales_refunds;
CREATE VIEW dash_monthly_sales_refunds AS
WITH monthly_sales AS (
  SELECT
    STRFTIME('%Y-%m', order_date) AS month,
    SUM(order_total) AS total_sales
  FROM cleaned_orders
  GROUP BY 1
),
monthly_refunds AS (
  SELECT
    STRFTIME('%Y-%m', o.order_date) AS month,
    SUM(r.refunded_amount) AS total_refunds
  FROM cleaned_returns r
  JOIN cleaned_orders o ON r.order_id = o.order_id
  GROUP BY 1
)
SELECT
  ms.month,
  ms.total_sales,
  COALESCE(mr.total_refunds, 0) AS total_refunds,
  ROUND(COALESCE(mr.total_refunds, 0) * 100.0 / NULLIF(ms.total_sales, 0), 2) AS refund_rate_pct
FROM monthly_sales ms
LEFT JOIN monthly_refunds mr ON ms.month = mr.month
ORDER BY ms.month;


-- ==========================================
-- 🔧 VIEW 4: dash_high_refund_customers
-- 📌 Purpose: Identify customers with high refund amounts and return frequencies.
-- 📋 Assumptions:
--     - `cleaned_customers` and `cleaned_returns` tables are available and linked by `customer_id`.
--     - `refunded_amount` on `cleaned_returns` represents the total refund for that return event.
-- 🗂️ Fields:
--     - customer_id, email, loyalty_tier, clv_bucket: Customer identifying and segmentation information.
--     - total_refunded_amount: The total monetary amount refunded to the customer.
--     - total_returns_count: The total number of return transactions initiated by the customer.
-- 🧠 Reasoning:
--     - Helps customer service and marketing teams identify customers who may be dissatisfied or abusing the returns policy.
--     - Can be used to segment customers for targeted communication or policy adjustments.
-- ==========================================
DROP VIEW IF EXISTS dash_high_refund_customers;
CREATE VIEW dash_high_refund_customers AS
SELECT
    c.customer_id,
    c.email,
    c.loyalty_tier,
    c.clv_bucket,
    SUM(r.refunded_amount) AS total_refunded_amount, -- Assumes `refunded_amount` is on cleaned_returns
    COUNT(r.return_id) AS total_returns_count -- Assumes `return_id` is the primary key of cleaned_returns
FROM
    cleaned_customers c
JOIN
    cleaned_returns r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, c.email, c.loyalty_tier, c.clv_bucket
ORDER BY
    total_refunded_amount DESC;
-- Limit in dashboard visualization, not in view, for flexibility


-- 📊 View: monthly_channel_sales_returns
-- 📌 Purpose: Return performance by order channel per month
-- ==========================================
DROP VIEW IF EXISTS dash_monthly_channel_sales_returns;
CREATE VIEW dash_monthly_channel_sales_returns AS
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
-- 🔧 VIEW 5: dash_regional_performance
-- 📌 Purpose: Compare sales, refunds, and order volume across U.S. regions, territories, and military zones using a reusable lookup.
-- 📋 Assumptions:
--     - State codes are extractable from `shipping_address` (2-letter uppercase state code near the end)
--     - Region lookup table (`us_state_region_lookup`) must be pre-populated
-- 🗂️ Fields:
--     - region: Region name based on state code (Midwest, South, Military, etc.)
--     - total_sales, total_refunds, refund_rate_pct, num_orders
-- 🧠 Reasoning:
--     - Simplifies region logic via join
--     - More maintainable, standardized, extensible
-- ==========================================

-- 🔁 Ensure region lookup exists
DROP TABLE IF EXISTS us_state_region_lookup;
CREATE TABLE us_state_region_lookup (
  state_code TEXT PRIMARY KEY,
  region_name TEXT
);

INSERT INTO us_state_region_lookup (state_code, region_name) VALUES
  -- Midwest
  ('IL', 'Midwest'), ('IN', 'Midwest'), ('IA', 'Midwest'), ('KS', 'Midwest'),
  ('MI', 'Midwest'), ('MN', 'Midwest'), ('MO', 'Midwest'), ('NE', 'Midwest'),
  ('ND', 'Midwest'), ('OH', 'Midwest'), ('SD', 'Midwest'), ('WI', 'Midwest'),

  -- Northeast
  ('CT', 'Northeast'), ('ME', 'Northeast'), ('MA', 'Northeast'), ('NH', 'Northeast'),
  ('NJ', 'Northeast'), ('NY', 'Northeast'), ('PA', 'Northeast'), ('RI', 'Northeast'),
  ('VT', 'Northeast'),

  -- South
  ('AL', 'South'), ('AR', 'South'), ('DE', 'South'), ('DC', 'South'),
  ('FL', 'South'), ('GA', 'South'), ('KY', 'South'), ('LA', 'South'),
  ('MD', 'South'), ('MS', 'South'), ('NC', 'South'), ('OK', 'South'),
  ('SC', 'South'), ('TN', 'South'), ('TX', 'South'), ('VA', 'South'),
  ('WV', 'South'),

  -- West
  ('AK', 'West'), ('AZ', 'West'), ('CA', 'West'), ('CO', 'West'),
  ('HI', 'West'), ('ID', 'West'), ('MT', 'West'), ('NV', 'West'),
  ('NM', 'West'), ('OR', 'West'), ('UT', 'West'), ('WA', 'West'),
  ('WY', 'West'),

  -- Territories
  ('AS', 'Territories'), ('GU', 'Territories'), ('MP', 'Territories'),
  ('PR', 'Territories'), ('VI', 'Territories'), ('FM', 'Territories'),
  ('MH', 'Territories'), ('PW', 'Territories'),

  -- Military
  ('AA', 'Military'), ('AE', 'Military'), ('AP', 'Military');

-- 🚀 Regionally grouped performance summary
DROP VIEW IF EXISTS dash_regional_performance;
CREATE VIEW dash_regional_performance AS
WITH order_with_region AS (
  SELECT
    o.order_id,
    o.order_total,
    COALESCE(lu.region_name, 'Other/Unknown') AS region
  FROM cleaned_orders o
  LEFT JOIN us_state_region_lookup lu
    ON UPPER(SUBSTR(TRIM(o.shipping_address), -8, 2)) = lu.state_code
),
return_agg AS (
  SELECT
    order_id,
    SUM(refunded_amount) AS total_refunded
  FROM cleaned_returns
  GROUP BY order_id
)
SELECT
  ow.region,
  SUM(ow.order_total) AS total_sales,
  SUM(COALESCE(ra.total_refunded, 0)) AS total_refunds,
  COUNT(DISTINCT ow.order_id) AS num_orders,
  ROUND(SUM(COALESCE(ra.total_refunded, 0)) * 100.0 / NULLIF(SUM(ow.order_total), 0), 2) AS refund_rate_pct
FROM order_with_region ow
LEFT JOIN return_agg ra ON ow.order_id = ra.order_id
GROUP BY ow.region
ORDER BY total_sales DESC;

-- ==========================================
-- 🔧 VIEW 6: dash_signup_cohort_performance
-- 📌 Purpose: Analyze customer lifetime value (CLV) and return rates by signup cohort.
-- 📋 Assumptions:
--     - `cleaned_customers`, `cleaned_orders`, `cleaned_returns` tables are available.
--     - `signup_date` is available on `cleaned_customers`.
--     - SQLite's STRFTIME function with '%Y-Q%q' is used for quarterly cohorting.
-- 🗂️ Fields:
--     - signup_quarter: The quarter (e.g., '2023-Q1') in which the customer signed up.
--     - avg_clv: The average total sales per customer in that cohort.
--     - avg_return_rate_pct: The average refund rate (refunds/sales) for customers in that cohort.
-- 🧠 Reasoning:
--     - Tracks the long-term value and quality of customers acquired in different periods.
--     - Helps evaluate the effectiveness of marketing campaigns or acquisition channels over time.
-- ==========================================
DROP VIEW IF EXISTS dash_signup_cohort_performance;
CREATE VIEW dash_signup_cohort_performance AS
WITH customer_sales AS (
  SELECT
    customer_id,
    SUM(order_total) AS total_sales
  FROM cleaned_orders
  GROUP BY customer_id
),
customer_refunds AS (
  SELECT
    customer_id,
    SUM(refunded_amount) AS total_refunds
  FROM cleaned_returns
  GROUP BY customer_id
),
customer_aggregates AS (
  SELECT
    c.customer_id,
    CASE
      WHEN c.signup_date IS NULL THEN 'unknown'
      ELSE STRFTIME('%Y', c.signup_date) || '-Q' || ((CAST(STRFTIME('%m', c.signup_date) AS INTEGER) - 1) / 3 + 1)
    END AS signup_quarter,
    COALESCE(cs.total_sales, 0) AS total_sales,
    COALESCE(cr.total_refunds, 0) AS total_refunds
  FROM cleaned_customers c
  LEFT JOIN customer_sales cs ON c.customer_id = cs.customer_id
  LEFT JOIN customer_refunds cr ON c.customer_id = cr.customer_id
)
SELECT
    signup_quarter,
    AVG(total_sales) AS avg_clv, -- Average lifetime value
    -- Calculate avg return rate, avoiding division by zero for customers with no sales
    AVG(CASE WHEN total_sales > 0 THEN total_refunds * 1.0 / total_sales ELSE 0 END) * 100 AS avg_return_rate_pct
FROM
    customer_aggregates
GROUP BY
    signup_quarter
ORDER BY
    signup_quarter;


-- ==========================================
-- 🔧 VIEW 7: dash_cohort_sales_returns_by_category
-- 📌 Purpose: Track return rates by signup cohort and product category.
-- 📋 Assumptions:
--     - `cleaned_customers`, `cleaned_orders`, `cleaned_order_items`, `cleaned_return_items`, `cleaned_product_catalog` are available.
--     - `signup_date` exists in `cleaned_customers`.
-- 🗂️ Fields:
--     - signup_quarter, product_category, avg_clv, avg_return_rate_pct
-- 🧠 Reasoning:
--     - Lets us assess product performance by acquisition cohort.
-- ==========================================
DROP VIEW IF EXISTS dash_cohort_sales_returns_by_category;
CREATE VIEW dash_cohort_sales_returns_by_category AS
WITH cohort_orders AS (
  SELECT
    c.customer_id,
    CASE
      WHEN c.signup_date IS NULL THEN 'unknown'
      ELSE STRFTIME('%Y', c.signup_date) || '-Q' || ((CAST(STRFTIME('%m', c.signup_date) AS INTEGER) - 1) / 3 + 1)
    END AS signup_quarter,
    oi.product_id,
    oi.unit_price * oi.quantity AS order_value
  FROM cleaned_customers c
  JOIN cleaned_orders o ON c.customer_id = o.customer_id
  JOIN cleaned_order_items oi ON o.order_id = oi.order_id
),
cohort_returns AS (
  SELECT
    c.customer_id,
    CASE
      WHEN c.signup_date IS NULL THEN 'unknown'
      ELSE STRFTIME('%Y', c.signup_date) || '-Q' || ((CAST(STRFTIME('%m', c.signup_date) AS INTEGER) - 1) / 3 + 1)
    END AS signup_quarter,
    ri.product_id,
    ri.refunded_amount
  FROM cleaned_customers c
  JOIN cleaned_returns r ON c.customer_id = r.customer_id
  JOIN cleaned_return_items ri ON r.return_id = ri.return_id
),
category_lookup AS (
  SELECT
    product_id,
    COALESCE(LOWER(TRIM(category)), 'unknown') AS product_category
  FROM cleaned_product_catalog
),
merged_orders AS (
  SELECT
    co.signup_quarter,
    cl.product_category,
    co.customer_id,
    SUM(co.order_value) AS total_sales
  FROM cohort_orders co
  JOIN category_lookup cl ON co.product_id = cl.product_id
  GROUP BY co.signup_quarter, cl.product_category, co.customer_id
),
merged_returns AS (
  SELECT
    cr.signup_quarter,
    cl.product_category,
    cr.customer_id,
    SUM(cr.refunded_amount) AS total_refunds
  FROM cohort_returns cr
  JOIN category_lookup cl ON cr.product_id = cl.product_id
  GROUP BY cr.signup_quarter, cl.product_category, cr.customer_id
),
cohort_summary AS (
  SELECT
    mo.signup_quarter,
    mo.product_category,
    mo.customer_id,
    mo.total_sales,
    COALESCE(mr.total_refunds, 0) AS total_refunds
  FROM merged_orders mo
  LEFT JOIN merged_returns mr
    ON mo.customer_id = mr.customer_id AND mo.signup_quarter = mr.signup_quarter AND mo.product_category = mr.product_category
)
SELECT
  signup_quarter,
  product_category,
  AVG(total_sales) AS avg_clv,
  AVG(CASE WHEN total_sales > 0 THEN total_refunds * 1.0 / total_sales ELSE 0 END) * 100 AS avg_return_rate_pct
FROM cohort_summary
GROUP BY signup_quarter, product_category
ORDER BY signup_quarter, product_category;


-- ==========================================
--         📦 DASHBOARD UTILITY TABLES
-- ==========================================

-- ==========================================
-- 🔧 VIEW 8: dash_return_rate_by_category
-- 📌 Purpose: Aggregate return rate metrics by product category
-- ==========================================
DROP VIEW IF EXISTS dash_return_rate_by_category;
CREATE VIEW dash_return_rate_by_category AS
WITH category_sales AS (
  SELECT
    COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
    SUM(oi.unit_price * oi.quantity) AS total_sales
  FROM cleaned_order_items oi
  LEFT JOIN cleaned_product_catalog pc ON oi.product_id = pc.product_id
  GROUP BY 1
),
category_returns AS (
  SELECT
    COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
    SUM(ri.refunded_amount) AS total_refunds
  FROM cleaned_return_items ri
  LEFT JOIN cleaned_product_catalog pc ON ri.product_id = pc.product_id
  GROUP BY 1
)
SELECT
  cs.product_category,
  cs.total_sales,
  COALESCE(cr.total_refunds, 0) AS total_refunds,
  ROUND(COALESCE(cr.total_refunds, 0) * 100.0 / NULLIF(cs.total_sales, 0), 2) AS refund_rate_pct
FROM category_sales cs
LEFT JOIN category_returns cr ON cs.product_category = cr.product_category;


-- ==========================================
-- 🔧 VIEW 9: dash_top_refund_products
-- 📌 Purpose: Identify top refund-heavy products by total refunded amount
-- ==========================================
DROP VIEW IF EXISTS dash_top_refund_products;
CREATE VIEW dash_top_refund_products AS
SELECT
  ri.product_id,
  COALESCE(LOWER(TRIM(pc.product_name)), 'unknown') AS product_name,
  COALESCE(LOWER(TRIM(pc.category)), 'unknown') AS product_category,
  COUNT(*) AS return_count,
  SUM(ri.refunded_amount) AS total_refunded
FROM cleaned_return_items ri
LEFT JOIN cleaned_product_catalog pc ON ri.product_id = pc.product_id
GROUP BY ri.product_id, pc.product_name, pc.category
ORDER BY total_refunded DESC;


-- ==========================================
-- 🔧 VIEW 10: dash_net_revenue_by_month
-- 📌 Purpose: Track monthly net revenue (sales minus refunds)
-- ==========================================
DROP VIEW IF EXISTS dash_net_revenue_by_month;
CREATE VIEW dash_net_revenue_by_month AS
WITH monthly_sales AS (
  SELECT
    STRFTIME('%Y-%m', order_date) AS month,
    SUM(order_total) AS total_sales
  FROM cleaned_orders
  GROUP BY 1
),
monthly_refunds AS (
  SELECT
    STRFTIME('%Y-%m', o.order_date) AS month,
    SUM(r.refunded_amount) AS total_refunds
  FROM cleaned_returns r
  JOIN cleaned_orders o ON r.order_id = o.order_id
  GROUP BY 1
)
SELECT
  ms.month,
  ms.total_sales,
  COALESCE(mr.total_refunds, 0) AS total_refunds,
  ms.total_sales - COALESCE(mr.total_refunds, 0) AS net_revenue
FROM monthly_sales ms
LEFT JOIN monthly_refunds mr ON ms.month = mr.month
ORDER BY ms.month;

-- ==========================================
-- 🔧 VIEW 11: dash_kpi_summary
-- 📌 Purpose: Single-row summary view for high-level dashboard KPIs
-- ==========================================
DROP VIEW IF EXISTS dash_kpi_summary;
CREATE VIEW dash_kpi_summary AS
WITH total_sales AS (
  SELECT SUM(order_total) AS total_sales FROM cleaned_orders
),
total_refunds AS (
  SELECT SUM(refunded_amount) AS total_refunds FROM cleaned_returns
),
customer_counts AS (
  SELECT COUNT(*) AS total_customers FROM cleaned_customers
),
order_counts AS (
  SELECT COUNT(*) AS total_orders FROM cleaned_orders
)
SELECT
  ts.total_sales,
  tr.total_refunds,
  ts.total_sales - tr.total_refunds AS net_revenue,
  oc.total_orders,
  cc.total_customers,
  ROUND(tr.total_refunds * 100.0 / NULLIF(ts.total_sales, 0), 2) AS refund_rate_pct
FROM total_sales ts, total_refunds tr, customer_counts cc, order_counts oc;

-- ==========================================
-- 🔧 VIEW 12: dash_view_registry
-- 📌 Purpose: Registry of dashboard views and their descriptions for Looker metadata or auditing
-- ==========================================
DROP VIEW IF EXISTS dash_view_registry;
CREATE VIEW dash_view_registry AS
SELECT 'dash_return_reason_quality_flags' AS view_name, 'Lookup table for normalized return reasons and quality flags' AS description
UNION ALL
SELECT 'dash_product_quality_risk_summary', 'Aggregated return + quality metrics per product'
UNION ALL
SELECT 'dash_monthly_sales_refunds', 'Sales vs refund trends by month'
UNION ALL
SELECT 'dash_high_refund_customers', 'Top customers by total refunds and return count'
UNION ALL
SELECT 'dash_regional_performance', 'Sales and refund rates by shipping region'
UNION ALL
SELECT 'dash_signup_cohort_performance', 'Customer CLV and return rate by signup quarter'
UNION ALL
SELECT 'dash_cohort_sales_returns_by_category', 'CLV and return rate by signup quarter and category'
UNION ALL
SELECT 'dash_return_rate_by_category', 'Sales vs refunds by product category'
UNION ALL
SELECT 'dash_top_refund_products', 'Top refund-heavy products by value'
UNION ALL
SELECT 'dash_net_revenue_by_month', 'Monthly net revenue after refunds'
UNION ALL
SELECT 'dash_monthly_channel_sales_returns', 'Monthly sales, returns, and refund rate by order channel'
UNION ALL
SELECT 'dash_kpi_summary', 'Top-level KPIs for dashboard cards';