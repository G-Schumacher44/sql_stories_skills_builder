<p align="center">
  <img src="repo_files/dark_logo_banner.png" width="1000"/>
  <br>
  <em>Scenario Design & Methodology</em>
</p>

<p align="center">
  <img alt="Guide" src="https://img.shields.io/badge/guide-storycrafting-blue">
  <img alt="Status" src="https://img.shields.io/badge/status-active-brightgreen">
  <img alt="Version" src="https://img.shields.io/badge/version-v0.2.0-blueviolet">
</p>

## 🎯 Purpose of This Document

This document explains how each SQL Story in this repo is created using a mix of synthetic data generation, structured business framing, and AI-assisted scenario design. The goal is to simulate realistic business questions and data challenges that strengthen SQL and analytical fluency.

---

## 🧬 Data Generation Strategy

All stories are powered by a dataset produced using the companion project:

➡️ [`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator)

That repo provides:
- Modular Python scripts for data simulation
- Scenario-based YAML configurations
- Controlled injection of data messiness

🗂️ This repository includes `db_builder_v3.zip`, located in the `ecom_data_gen_output/` directory.

The output includes:
- Clean CSVs for each table (`orders`, `order_items`, `returns`, etc.)
- A zip archive with loading assets:  
  `ecom_data_gen_output/db_builder_v3.zip`

Inside that zip:
- `*.csv` files (one per table)
- `load_data.sql` to construct the schema and load into SQLite

---

### 🧪 Mess Injection (Realism Tuning)

The data generator supports configurable “mess” levels:
- `none`: perfectly clean, ideal for baselines or learners
- `medium`: includes nulls, case issues, date shifts, return spikes
- `heavy`: simulates real-world chaos — fuzzy joins, data mismatches, and edge-case outliers

This messiness emulates POS systems or early-stage data warehouses where governance is still maturing.

> The included database was configured with a `medium` mess injection.

---

## 🤖 AI's Role in Story Design

AI acts as a **co-author and validator**, helping shape business scenarios around each dataset. Contributions include:

- Business context and stakeholder goals
- Analytical framing and key metrics
- Prompt engineering for SQL challenges
- Narrative tone and documentation

AI helps keep every story grounded, engaging, and useful — from beginner tutorials to portfolio-grade projects.

---

## 📦 Story Format

Each story lives in its own folder (e.g., `story_01_inventory_accuracy/`) and follows a consistent structure:

- A `scenario_XX_name.md` brief describing the context and goals
- A `sql_sessions/` subdirectory that contains the SQL scripts for the automated pipeline:
  - `build_*.sql` scripts create the temporary views for analysis.
  - `cleanup_*.sql` scripts drop the views after the pipeline runs.
- Optional: Jupyter notebooks, QA notes, or other supporting artifacts.

---

## 🔄 Reusability

Every scenario is modular and remixable:
- Regenerate data with updated YAML for infinite variety
- Extend queries into notebooks or dashboards
- Fork scenarios into cleanup, reporting, or advanced SQL exercises

---

## 🌱 Why This Matters

Real analysts deal with:
- Unclear business questions
- Messy, mismatched data
- High expectations for clarity and insight

These stories replicate that — helping you build SQL muscle in realistic contexts with just the right level of friction.

> _Every scenario is a mini sandbox for growing analytical confidence and narrative clarity._

<p align="center">
  <a href="README.md">🏠 <b>Main README</b></a>
  &nbsp;·&nbsp;
  <a href="USAGE.md">📖 <b>Usage Guide</b></a>
  &nbsp;·&nbsp;
  <a href="storycrafting.md">🛠️ <b>Storycrafting</b></a>
  &nbsp;·&nbsp;
  <a href="sample_ai_prompt.md">🤖 <b>AI Prompt Guide</b></a>
</p>

<p align="center">
  <sub>✨ SQL · Python · Storytelling ✨</sub>
</p>