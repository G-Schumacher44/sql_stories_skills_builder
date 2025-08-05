-- ==============================================
-- 📍 File: export_cleaned_tables.sql
-- 📌 Purpose: Export all 'cleaned_*' views to CSV files.
-- ⚠️ Usage: This script is intended to be run with the SQLite3 command-line tool.
--    Example: sqlite3 ecom_retailer.db < story_05_vp_request/sql_sessions/export_cleaned_tables.sql
-- ==============================================

.headers on
.mode csv

.output story_05_vp_request/output_data/cleaned_tables/cleaned_customers.csv
SELECT * FROM cleaned_customers;

.output story_05_vp_request/output_data/cleaned_tables/cleaned_orders.csv
SELECT * FROM cleaned_orders;

.output story_05_vp_request/output_data/cleaned_tables/cleaned_order_items.csv
SELECT * FROM cleaned_order_items;

.output story_05_vp_request/output_data/cleaned_tables/cleaned_returns.csv
SELECT * FROM cleaned_returns;

.output story_05_vp_request/output_data/cleaned_tables/cleaned_return_items.csv
SELECT * FROM cleaned_return_items;

.output story_05_vp_request/output_data/cleaned_tables/cleaned_product_catalog.csv
SELECT * FROM cleaned_product_catalog;

.output stdout