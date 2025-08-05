#!/bin/bash
echo "🚀 Running all SQL scripts into ecom_retailer.db"
(
  echo ".headers on"
  cat \
    story_05_vp_request/sql_sessions/ecom_retailer_01_cleaning.session.sql \
    story_05_vp_request/sql_sessions/ecom_retailer_02_core_metrics.session.sql \
    story_05_vp_request/sql_sessions/ecom_retailer_03_segementation.session.sql \
    story_05_vp_request/sql_sessions/ecom_retailer_04_logistics_summary.session.sql \
    story_05_vp_request/sql_sessions/ecom_retailer_00_dashboards.sql \
    story_05_vp_request/sql_sessions/export_cleaned_tables.sql \
    story_05_vp_request/sql_sessions/export_views.sql
) | sqlite3 ecom_retailer.db