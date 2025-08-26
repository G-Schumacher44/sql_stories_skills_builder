# 📦 Scenario 01: Inventory Accuracy Check for Fulfillment Team

## 🧭 Background

As our ecommerce startup scales fulfillment through a national warehouse network, the **Fulfillment Team** has noticed inconsistencies between reported stock and what can actually be shipped. These discrepancies have resulted in order delays, partial shipments, and a spike in return processing time.

To address this, the team is requesting a lightweight inventory audit to validate recorded stock levels, detect discrepancies in order fulfillment, and flag product categories that may be contributing to fulfillment friction.

This foundational analysis will help uncover early signs of operational misalignment and build confidence in our warehouse inventory tracking system.

## 🧑‍💼 Stakeholder

**Name:** Fulfillment Team Lead  
**Objective:** Ensure inventory accuracy and reduce fulfillment-related delays.

---

## 🎯 Business Objective

Develop a SQL-powered diagnostic report to:

- Compare `inventory_quantity` vs. units sold per product
- Identify SKUs with potential overselling (where fulfilled quantity exceeds recorded stock)
- Detect underperforming categories with unshipped inventory
- Highlight patterns in `order_items` vs. `return_items` for potential mis-picks or warehouse issues
- Summarize inventory utilization by category

---

## 🧩 Available Data

The report will use the following tables from the database:

- `product_catalog`: Product ID, name, category, unit price, inventory quantity
- `order_items`: Quantity sold per product
- `return_items`: Items returned by product and quantity
- `orders`: Order metadata (to join or filter)
- `returns`: Metadata on return types and timing

---

## 🛠️ Key Metrics

Focus the diagnostic around:

- **Inventory Utilization Ratio**: (Total Sold - Total Returned) ÷ Inventory
- **Oversold Products**: SKUs where units sold > recorded inventory
- **High Stock Low Sales Products**: Inventory on hand but low movement
- **Category-Level Inventory Accuracy**
- **Return Rates by SKU** (linked to inventory issues)

🛠 Note on Data Source:  
This diagnostic uses `ecom_retailer.db`, a simulated ecommerce operations database. All quantities, orders, and returns are generated to reflect typical ecommerce fulfillment behaviors.

>✍️ Analytical Framing:  
This scenario introduces inventory diagnostics, joins across fulfillment and return logic, and starter KPI creation — ideal for developing SQL skills and understanding operational data structure.

<div align="center">
  <a href="#">
    ⬆️ <b>Back to Top</b>
  </a>
</div>

<p align="center">
  <a href="../README.md">🏠 <b>Main README</b></a>
  &nbsp;·&nbsp;
  <a href="../USAGE.md">📖 <b>Usage Guide</b></a>
  &nbsp;·&nbsp;
  <a href="../storycrafting.md">🛠️ <b>Storycrafting</b></a>
  &nbsp;·&nbsp;
  <a href="../sample_ai_prompt.md">🤖 <b>AI Prompt Guide</b></a>
</p>

<p align="center">
  <sub>✨ SQL · Python · Storytelling ✨</sub>
</p>