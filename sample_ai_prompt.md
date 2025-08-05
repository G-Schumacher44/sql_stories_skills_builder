# 🤖 Sample AI Prompt: Build a Scenario from `ecom_retailer.db`

This prompt is designed to generate realistic, portfolio-quality SQL scenarios using the simulated ecommerce database provided in this repository.

---

## 📄 Prompt for AI Tools (e.g. GPT-4, Gemini)

```text
I have access to a SQLite database named `ecom_retailer.db` — generated for an e-commerce simulation project.

It contains realistic but synthetic data across the following tables:

- `orders` — includes order_id, order_date, region, channel, shipping_type, customer_id, and order_total
- `order_items` — line-level details of each order: product_id, quantity, unit_price
- `returns` — return_id, order_id, return_reason, refunded_amount, return_date
- `return_items` — product-level breakdown of what was returned
- `customers` — customer_id, signup_date, loyalty_tier, region
- `product_catalog` — product_id, category, name, original_price, discounted_price

The dataset includes light-to-moderate messiness (nulls, inconsistent values, date fuzzing).

---

Please help me create a **realistic SQL scenario** based on this database — one that simulates a challenge an analyst or analytics engineer might face in the first 12–18 months of working at a direct-to-consumer brand. I'd like:

1. A clear business context with a stakeholder role (VP, Ops Manager, etc.)
2. 2–3 high-level business questions
3. A list of key SQL metrics or outputs to produce (with definitions)
4. Any wrinkles or data challenges to add realism (e.g. incomplete records, segment breakdowns)
5. A suggestion for extending this into a dashboard or Jupyter notebook deliverable
6. Optional: How this scenario could evolve into a multi-part project

Please keep the tone grounded and professional, with enough narrative to make it portfolio-ready.
```

---

⬅️ [Return to Main Project README](README.md)