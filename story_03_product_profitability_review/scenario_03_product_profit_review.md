# 📦 Scenario 03: Product Profitability Review for Finance Team

## 🧭 Background

Following a strong growth year, the **Finance Team** is assessing which products are driving real profitability versus those contributing to high operational costs or refund exposure. While top-line sales have climbed, the actual value captured per product varies widely due to category margins, return activity, and shipping costs.

To support upcoming SKU rationalization decisions, Finance is requesting a profitability review — focused not just on total revenue but on net margin contribution after returns and shipping.

This analysis will serve as a foundation for pricing reviews and category-level investment decisions in the upcoming fiscal year.

## 🧑‍💼 Stakeholder

**Name:** Director of Finance  
**Objective:** Identify low-margin or high-return products that erode net profitability.

---

## 🎯 Business Objective

Create a SQL-powered profitability report that:

- Calculates gross revenue, net revenue (after returns), and estimated margin per SKU
- Identifies products with high revenue but low margin
- Highlights top and bottom performing categories by net margin
- Estimates impact of return-related losses on product-level profitability
- Links return reasons to unprofitable SKUs

---

## 🧩 Available Data

The analysis will use:

- `order_items`: Quantity sold, price, category, product name
- `return_items`: Quantity and value returned per SKU
- `returns`: Return reasons (to classify avoidable vs. unavoidable)
- `product_catalog`: Unit price and margin (proxy: unit_price × assumed margin %)
- `orders`: For total order count and shipping cost (optional add-on)

---

## 🛠️ Key Metrics

The diagnostic will compute:

- **Gross Revenue per SKU** = unit_price × quantity_sold
- **Net Revenue per SKU** = Gross – Refunded
- **Margin Estimate** = Net Revenue × margin proxy (or subtract estimated COGS)
- **Return Rate by SKU** = units returned ÷ units sold
- **High Refund Loss Drivers** = SKUs with high returns eroding margin

🛠 Note on Data Source:  
This scenario uses `ecom_retailer.db`, simulating product-level sales and return behavior. Product profitability is approximated via unit_price and returned value; no direct COGS data is included.

>✍️ Analytical Framing:  
This scenario introduces profitability metrics, negative contribution margin detection, and return-linked cost exposure — ideal for growing SQL practitioners ready for financial-style diagnostics.