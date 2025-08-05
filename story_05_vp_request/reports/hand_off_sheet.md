# 📦 Scenario 05 — Project Handoff Sheet  
*Retail Returns Diagnostic | 2025 YTD Revenue| Prepared for: VP of Sales*

---

## 🧭 Project Summary

This analysis was commissioned by the VP of Sales to understand patterns behind rising return rates and declining customer profitability across channels. It combines SQL-based diagnostics with stakeholder-focused deliverables.

---

## 🎯 Key Business Questions

- Which products, customers, or channels are most impacted by returns?
- Are certain fulfillment practices (e.g., expedited shipping) linked to higher return rates?
- How can we segment customers by value and risk to guide retention strategy?

---

## 📊 Dashboard

🔗 **Live Looker Studio Dashboard**  
[View Dashboard](https://lookerstudio.google.com/reporting/e5f1454c-c8e4-481f-9ac8-375a3bdd289c)

Includes filters by cohort, loyalty tier, return reason, and fulfillment channel.

---

## 🗂️ Deliverables Index

### ✅ Cleaned Source Data  
Location: `output_data/cleaned_tables/`
- `cleaned_customers.csv`  
- `cleaned_orders.csv`  
- `cleaned_order_items.csv`  
- `cleaned_returns.csv`  
- `cleaned_return_items.csv`  
- `cleaned_product_catalog.csv`  

📦 Combined export:  
- `cleaned_tables_export.xlsx`

---

### 📐 Views + Aggregates  
Location: `output_data/views/`
- `monthly_sales_returns_summary.csv`  
- `top_customers_by_returns.csv`  
- `return_rate_by_product.csv`  
- `shipping_return_impact_summary.csv`  
- `customer_segment_sales_returns.csv`  
- *(and 8 more views)*

📦 Combined export:  
- `views_export.xlsx`  
- `vp_req_analysis_export.xlsx` (used for dashboard)

---

### 📘 Report & Analysis
- [`Sales_Diagnostic Live Dashboard`](https://lookerstudio.google.com/reporting/e5f1454c-c8e4-481f-9ac8-375a3bdd289c) -  interactive dashboard hosted in Looker Studio, covering metrics from the report
- `Sales_Diagnostic.pdf` – static PDF report of the dashboard
- `Executive_Retail_Returns_Report.ipynb` – technical walkthrough

---

### 💻 SQL Sessions  
Location: `sql_sessions/`
- Cleaning: `ecom_retailer_01_cleaning.session.sql`
- Metrics: `ecom_retailer_02_core_metrics.session.sql`
- Segments: `ecom_retailer_03_segementation.session.sql`
- Logistics: `ecom_retailer_04_logistics_summary.session.sql`
- Dashboards: `ecom_retailer_00_dashboards.sql`
- Exports: `export_cleaned_tables.sql`, `export_views.sql`
- Runner: `run_all.sh`

---

### 🐍 Python Scripts
Location: `python_scripts/`
- `csv_to_xlsx.py` – table consolidation script
- `g_drive_uploader.py` – upload utility

---

## 📌 Notes

- This scenario was built using **synthetic data** with realistic structure and medium mess injection.
- Data pipeline and SQL layers were manually designed, with AI used for documentation refinement.
- Scenario 05 was completed as a **demo case** of full-cycle analytics work.

---

## ✅ Final Status: Delivered
All required assets have been generated, exported, and structured for reuse.