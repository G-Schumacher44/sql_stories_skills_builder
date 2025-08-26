# 🛒 Scenario 04: Cart & Customer Behavior Analysis

## 🧭 Background

As acquisition scales, leadership has noticed that **a large share of revenue is lost at the cart stage**. Customers add products, but many never convert — and there’s little visibility into why. With new cart data available, the Growth & Retention team wants to understand **who abandons, what they abandon, and which customers are most likely to re-engage**.

This scenario pushes beyond descriptive inventory/retention audits into **behavioral analysis**, where business rules and assumptions must be made explicit (e.g., what counts as a “converted cart,” how to link carts to orders, what time windows to use).

## 🧑‍💼 Stakeholder

**Name:** Director of Growth & Retention  
**Objective:** Reduce abandonment, recover lost revenue, and guide re-engagement campaigns based on real customer behavior.

---

## 🎯 Business Objective

Build a SQL-driven diagnostic that:

- Maps the **cart funnel** (open → converted vs abandoned) over time.
- Quantifies the **value left behind in abandoned carts** and identifies top SKUs/categories driving that leakage.
- Segments cart behavior by **customer attributes** (signup channel, loyalty tier, CLV bucket).
- Measures **re-engagement** (orders placed within 7 days of abandonment) to surface “savable” customers.
- Analyzes **time-to-order** for converted carts to understand purchase lag.

---

## 🧩 Available Data

- `shopping_carts` → `cart_id`, `customer_id`, `created_at`, `status`  
  *(normalize with `LOWER(TRIM(status))` to handle case variants)*
- `cart_items` → `cart_id`, `product_id`, `quantity`, `unit_price`  
  *(dedupe on `(cart_id, product_id)` when aggregating SKUs)*
- `customers` → `customer_id`, `signup_channel`, `loyalty_tier`, `clv_bucket`, `signup_date`
- `orders` → `order_id`, `customer_id`, `order_date`
- `product_catalog` → product attributes for SKU/category rollups

---

## 🛠️ Key Metrics

- **Cart Conversion Rate** = converted ÷ total carts
- **Abandonment Rate** = abandoned ÷ total carts
- **Abandoned Cart Value** = Σ(quantity × unit_price) for abandoned carts
- **Top Abandoned SKUs / Categories** by value left
- **Re-engagement Rate (7d)** = % of customers with abandoned carts who place an order ≤7 days later
- **Time-to-Order (converted)** = days from cart creation → first order

🛠 Note on Data Source:  
This diagnostic uses `ecom_retailer_v3.db`, a simulated ecommerce dataset with behaviorally plausible customer patterns. All cohorts and metrics are fully reproducible for learning purposes.

>✍️ Analytical Framing:  
This scenario introduces cohort grouping, temporal analysis, segmentation, and churn proxy signals — ideal for building intermediate SQL and customer analytics skills.

---

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