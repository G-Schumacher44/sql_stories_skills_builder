# 📦 Scenario 02: Customer Retention Snapshot for Marketing Team

## 🧭 Background

As the ecommerce startup heads into its second year, the **Marketing Team** is focused on improving customer retention. While acquisition campaigns have been successful, internal data shows that a significant portion of customers make only one purchase and never return.

To inform new loyalty and re-engagement strategies, the Marketing Team has requested a customer retention snapshot to understand how signup cohorts are behaving over time — and which customer attributes signal higher lifetime value.

This early-stage behavioral segmentation will shape future personalization efforts and budget allocation.

## 🧑‍💼 Stakeholder

**Name:** Head of Retention Marketing  
**Objective:** Increase customer lifetime value by improving retention among early and mid-stage cohorts.

---

## 🎯 Business Objective

Develop a SQL-powered cohort analysis that will:

- Break customers into cohorts based on signup month
- Calculate repeat purchase rate per cohort
- Segment customers by `loyalty_tier`, `clv_bucket`, and `signup_channel`
- Identify high-retention customer profiles and drop-off patterns
- Surface early indicators of churn risk

---

## 🧩 Available Data

The report will use the following tables from the database:

- `customers`: Signup date, loyalty tier, channel, CLV bucket
- `orders`: Order dates, order totals, customer ID, channel
- `returns`: Return timing and refund amount (optional)
- `product_catalog`: For optional spend category analysis

---

## 🛠️ Key Metrics

The report will focus on:

- **Repeat Purchase Rate by Cohort**
- **First-to-Second Purchase Conversion** (per signup month)
- **Average Time Between Orders**
- **Retention by Loyalty Tier**
- **CLV Distribution per Signup Channel**

🛠 Note on Data Source:  
This diagnostic uses `ecom_retailer.db`, a simulated ecommerce dataset with behaviorally plausible customer patterns. All cohorts and metrics are fully reproducible for learning purposes.

>✍️ Analytical Framing:  
This scenario introduces cohort grouping, temporal analysis, segmentation, and churn proxy signals — ideal for building intermediate SQL and customer analytics skills.