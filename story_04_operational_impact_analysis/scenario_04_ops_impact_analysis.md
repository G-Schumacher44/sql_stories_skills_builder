# 📦 Scenario 04: Operational Impact Analysis for Logistics Strategy

## 🧭 Background

As return volume continues to erode profitability, leadership is questioning whether operational decisions — like offering expedited shipping — may be unintentionally increasing refund risk. The **Operations Strategy Team** suspects that faster delivery may not always mean better outcomes, especially if customers are impulse-buying or receiving damaged goods due to rushed fulfillment.

They’ve requested a strategic diagnostic to investigate whether shipping speed, order channel, or fulfillment method are correlated with increased return rates and operational losses.

The goal is to find levers within the operation that could be tuned to reduce returns without harming customer experience.

## 🧑‍💼 Stakeholder

**Name:** Director of Operations Strategy  
**Objective:** Identify operational patterns contributing to return risk and fulfillment costs.

---

## 🎯 Business Objective

Build a SQL-powered diagnostic that will:

- Compare return rates by `shipping_speed` (e.g., expedited vs. standard)
- Evaluate return patterns by `order_channel` (e.g., web, social, phone)
- Identify whether higher shipping costs correlate with higher refunds
- Analyze whether certain regions or products are more affected by fast shipping
- Detect potential links between `return_reason` and operational factors

---

## 🧩 Available Data

The analysis will use:

- `orders`: Includes shipping speed, shipping cost, channel, region, and customer metadata
- `returns`: Contains return reasons, amount refunded, return type
- `return_items`: Specific products returned, quantity, and refund value
- `order_items`: Product-category context to enrich return drivers

---

## 🛠️ Key Metrics

The diagnostic will evaluate:

- **Return Rate by Shipping Speed** = returns ÷ total orders per speed
- **Refund % of Order Value** by Channel and Speed
- **Average Refund per Return** by Shipping Type
- **Top Refund Reasons by Shipping Speed**
- **High-Cost Operational Patterns** (e.g., expensive shipping + frequent return)

🛠 Note on Data Source:  
This diagnostic uses `ecom_retailer.db`, a simulated ecommerce operations dataset with realistic logistics and return metadata. Operational costs are approximated via shipping cost and refunded amount.

>✍️ Analytical Framing:  
This scenario blends operational efficiency, customer behavior, and cost impact — ideal for experienced SQL analysts looking to model real-world logistics tradeoffs.