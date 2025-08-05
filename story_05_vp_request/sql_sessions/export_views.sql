-- ==============================================
-- 📍 File: export_views.sql
-- 📌 Purpose: Export all dashboard and analysis views to CSV files.
-- ⚠️ Usage: This script is intended to be run with the SQLite3 command-line tool.
--    Example: sqlite3 ecom_retailer.db < story_05_vp_request/sql_sessions/export_views.sql
-- ==============================================

.headers on
.mode csv

.output story_05_vp_request/output_data/views/category_monthly_sales_returns.csv
SELECT * FROM category_monthly_sales_returns;

.output story_05_vp_request/output_data/views/customer_segment_sales_returns.csv
SELECT * FROM customer_segment_sales_returns;

.output story_05_vp_request/output_data/views/monthly_channel_sales_returns.csv
SELECT * FROM monthly_channel_sales_returns;

.output story_05_vp_request/output_data/views/monthly_clv_sales_returns.csv
SELECT * FROM monthly_clv_sales_returns;

.output story_05_vp_request/output_data/views/monthly_loyalty_sales_returns.csv
SELECT * FROM monthly_loyalty_sales_returns;

.output story_05_vp_request/output_data/views/monthly_sales_returns_summary.csv
SELECT * FROM monthly_sales_returns_summary;

.output story_05_vp_request/output_data/views/monthly_signup_channel_sales_returns.csv
SELECT * FROM monthly_signup_channel_sales_returns;

.output story_05_vp_request/output_data/views/region_summary_by_state.csv
SELECT * FROM region_summary_by_state;

.output story_05_vp_request/output_data/views/return_rate_by_product.csv
SELECT * FROM return_rate_by_product;

.output story_05_vp_request/output_data/views/return_reason_summary.csv
SELECT * FROM return_reason_summary;

.output story_05_vp_request/output_data/views/shipping_return_impact_summary.csv
SELECT * FROM shipping_return_impact_summary;

.output story_05_vp_request/output_data/views/top_customers_by_returns.csv
SELECT * FROM top_customers_by_returns;

.output story_05_vp_request/output_data/views/shipping_return_impact_summary.csv
SELECT * FROM shipping_return_impact_summary;

.output story_05_vp_request/output_data/views/monthly_payment_sales_returns.csv
SELECT * FROM monthly_payment_sales_returns;

.output story_05_vp_request/output_data/views/return_rate_by_product.csv
SELECT * FROM return_rate_by_product;


.quit