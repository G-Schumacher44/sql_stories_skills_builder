<p align="center">
  <img src="repo_files/dark_logo_banner.png" width="1000"/>
  <br>
  <em>SQL Training Simulation & Educational Toolkit</em>
</p>

<p align="center">
  <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="Status" src="https://img.shields.io/badge/status-active-brightgreen">
  <img alt="Version" src="https://img.shields.io/badge/version-v0.2.0-blueviolet">
</p>

## 📚 SQL Stories

SQL Stories is a simulation-based training suite designed to help data professionals grow their analytical skills through realistic business scenarios. Each "story" is a self-contained project with:

- A business context and stakeholder brief
- Rich, synthetic data (via our companion generator)
- Guided SQL exercises or open-ended diagnostic challenges
- An automated pipeline to upload results directly to Google Sheets

Whether you're a beginner learning joins or a practitioner refining your storytelling with SQL, this repo offers a narrative-driven way to build confidence and context.

Each scenario is modular and remixable. You can treat them as:
- SQL interview prep modules
- Portfolio-ready case studies
- Practice environments for real-world patterns

> 🧠 Inspired by real analyst tasks, tuned for solo practice, and built to scale with your growth.

## 🧩 TL;DR

- This repo contains SQL projects that simulate real-world business problems.
- All data is generated from the [ecom_sales_data_generator](https://github.com/G-Schumacher44/ecom_sales_data_generator) repository
- Each story lives in its own folder and includes markdown briefs 
- Scenarios use clean or messy data to simulate real-life friction
- GPT-4 was used to generate each scenario's narrative
- Great for practicing joins, cohorts, KPIs, and data storytelling

## 🧭 Explore the Scenarios

Dive into any of the scenarios below to start practicing. Each link will take you to the business brief, which outlines the stakeholder, objectives, and available data for that challenge.

- [**📦 Scenario 01: Inventory Accuracy Check**](story_01_inventory_accuracy/sceanrio_01_inventory_accuracy.md)
  - *Focus: Operational Analytics, KPI Creation, Fulfillment Logic*
- [**📦 Scenario 02: Customer Retention Snapshot**](story_02_customer_retention_snapshot/scenari_02_retention_snapshot.md)
  - *Focus: Cohort Analysis, Segmentation, Temporal SQL*
- [**📦 Scenario 03: Product Profitability Review**](story_03_product_profitability_review/scenario_03_product_profit_review.md)
  - *Focus: Financial Analysis, Contribution Margin, Cost Allocation*
- [**🛒 Scenario 04: Cart & Customer Behavior Analysis**](story_04_cart_behavior_analysis/scenario_04_cart_behavior_analysis.md)
  - *Focus: Behavioral Analysis, Funnel Metrics, Sessionization*
- [**📦 Scenario 05: Diagnostic Request from the VP of Sales**](story_05_vp_request/scenario_05_vp_request.md)
  - *Focus: Exploratory Data Analysis, Dashboarding, Executive Reporting*

---

### ✨ See a Finished Example

To see how these scenarios can be turned into a full-fledged portfolio piece, check out the companion repository:

➡️ [**SQL Stories: Portfolio Demo**](https://github.com/G-Schumacher44/sql_stories_portfolio_demo)

This showcase demonstrates a complete workflow — from stakeholder framing to SQL analysis, deliverables, and dashboards.


## 🧭 Orientation & Getting Started

<details>
<summary><strong>🧠 Notes from the Dev Team</strong></summary>

**Task and Purpose**

This project was born out of a need to go beyond surface-level SQL practice. It started as a personal challenge — to create a learning environment that mimicked real work: ambiguous prompts, messy data, and evolving business logic. The online resources available felt too clean, too isolated, or too abstract.

That quest led to building a custom data generator (now maintained in the [`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator) repo) and structuring a storytelling system that could scale.

Along the way, it became clear that this system — combining simulated data, scenario design, and AI tooling — could benefit others too. 

</details>

<details>
<summary><strong>🗺️ About the Project Ecosystem</strong></summary>

This repository is one part of a larger, interconnected set of projects. Here’s how they fit together:

* **[`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator)** `(The Engine)`  
  Generates realistic, relational ecommerce datasets. This extension imports it and keeps that repo focused on synthesis.
* **[`ecom-datalake-exten`](https://github.com/G-Schumacher44/ecom-datalake-exten)** `(This Repo · The Lake Layer)`  
  Converts generator output to Parquet, attaches lineage, and publishes to raw/bronze buckets.
* **[`sql_stories_skills_builder`](https://github.com/G-Schumacher44/sql_stories_skills_builder)** `(Learning Lab)`  
  Publishes the story modules and exercises that use these datasets for hands-on practice.
* **[`sql_stories_portfolio_demo`](https://github.com/G-Schumacher44/sql_stories_portfolio_demo/tree/main)** `(The Showcase)`  
  Curates the best case studies into a polished portfolio for professional storytelling.
* **gcs-automation-project** `(In Development · The Orchestrator)`  
  Planned orchestration layer for scheduling backlog runs, triggering BigQuery loads/merges, and coordinating downstream DAGs.

</details>

<details>
<summary>📐 What’s Included</summary>

- `db_builder_v3.zip` — Zipped CSVs and a schema script to build the database.
- `ecom_retailer_v3.db` — A fully built SQLite database using the latest v3 schema.
- Five prebuilt SQL scenarios (difficulty levels 1–5)    
- `storycrafting.md` — Internal design doc on how stories are framed and built.
- **Data Pipeline Components:**
  - `run_story.sh` - runner script
  - `gsheets_uploader.py` - dynamic data transfer script
  - `secrets_template.yaml` - Template for API secrets and credentials.
  - `stories_config_template.yaml` - Template for story-specific path configurations.
- `scripts/check_db.py` - A simple diagnostic tool to validate database integrity.
- `scripts/csv_to_xlsx.py` - A utility script to convert `.csv` files to `.xlsx` format.

> 🚫 Not included in this repo: the data generator itself — that's housed in [`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator).

</details>

<details>
<summary><strong>🫆 Version Release Notes</strong></summary>

**v0.2.0 *Update* - Database v0.3.0 with enriched data and new stories**

- **Story Module 4 & 5 Update:** to better align with `ecom_retailer_v3.db`
- **Build Package:** updated to `ecom_retailer_v3.db` (legacy `ecom_retailer.db` available with v0.2.0 release package)
- **Deprecated v0.2.0 story_05_vp_request demo:** Demo is now available in [`VP Request Case Study Repository`](https://github.com/G-Schumacher44/VP-Request)
- **Google Sheets Pipline:** The below files have been added to add depth and ease of use for deliverable production;
  - [g_drive_uploader.py](scripts/g_drive_uploader.py)
  - [secrets_templates.yaml](secrets_template.yaml)  
  - [stories_config_template.yaml](stories_config_template.yaml) 
  - [Usage Guide](USAGE.md)
- **Additional Script:** Two additonal Scripts Added
  - [csv_to_xlsx.py:](scripts/csv_to_xlsx.py) Convert csv files to .xlxs format
  - [check_db.py:](scripts/check_db.py) a quick database diagnostic tool.

>>`ecom_sales_data_generator` - **v0.3.0 update** [*Ecommerce Sales Data Generator Repository*](https://github.com/G-Schumacher44/ecom_sales_data_generator)
>>- **Enriched Cart & Session Analysis:** Added detailed timestamps (created_at, updated_at, added_at) and distinguished between abandoned and emptied carts for granular analysis of user intent.
>>- **Advanced Behavioral Modeling:** Introduced highly stratified customer behavior based on signup_channel and loyalty_tier, influencing repeat purchase rates, timing, and product preferences.
>>- **Earned Customer Status:** Implemented logic for customers to "earn" their loyalty_tier and clv_bucket based on cumulative spend, creating a realistic customer lifecycle.
>>- **Long-Tail Churn & Reactivation:** Added simulation of long-term dormancy and customer reactivation for advanced LTV analysis.


**Planned for v0.3.0**
- More SQL stories (CR 6 and beyond)
- Richer simulation data: enhanced return logic, behavior, and join depth
- Optional notebook integrations and user prompts
- Scenario templating support and QA checklists

**v0.1.0 — Alpha Launch**
- Includes fully built database and `db_builder_v3.zip`
- Five scenarios with ascending complexity (CR 1–5).
- Scenario 5 demo includes full workflow: deliverables, notebooks, exports
- AI-assisted design used for scenario crafting, QA, and documentation
- Includes full storycrafting methodology doc


</details>

<details>
<summary>⚙️ Project Structure</summary>

```
sql_stories/
├── ecom_data_gen_output/
│   └── db_builder_v3.zip               # Zipped data + schema loader (CSVs + SQL)
├── creds/
│   └── sheets_creds_template.json   # Google Sheets API credentials template
│                 
├── scripts/
│   ├── gsheets_uploader.py          # Python script to upload query results to G-Sheets
│   ├── check_db.py                  # Utility to validate the database schema
│   └── csv_to_xlsx.py               # Utility to convert CSVs to Excel format
│   
├── repo_files/
│   └── dark_logo_banner.png         # Project header image
│
├── story_01_inventory_accuracy/
│   └── scenario_01_inventory_accuracy.md
│
├── story_02_customer_retention_snapshot/
│   └── scenario_02_retention_snapshot.md
│
├── story_03_product_profitability_review/
│   └── scenario_03_product_profit_review.md
│
├── story_04_operational_impact_analysis/
│   └── scenario_04_ops_impact_analysis.md
│
├── story_05_vp_request/                 
│   └── scenario_05_vp_request.md      
│
├── .gitignore                         # Standard ignore rules
├── ecom_retailer_v3.db                # Pre-built SQLite database
├── environment.yml                    # Conda environment specification
├── README.md                          # Main project introduction
├── secrets_template.yaml              # Template for pipeline secrets (API keys, etc.)
├── run_story.sh                       # Master script to execute a story's SQL and run the pipeline
├── stories_config_template.yaml       # Template for story-specific path configurations
├── USAGE.md                           # Detailed usage guide for the data pipeline
├── requirements.txt                   # pip dependency list
└── storycrafting.md                   # Internal design + methodology doc
```

</details>

<details>

<summary>💡 Sample AI Prompt for Scenario Design</summary>

💡 Need ideas? Check out the full [Sample AI Prompt](sample_ai_prompt.md) — designed to help you or others generate new business scenarios using the `ecom_retailer_v3.db` dataset.

It includes:
- Database schema summary
- A detailed AI prompt for tools like GPT-4
- Suggestions for metrics, stakeholders, and deliverables

</details>

___


### 🛠 Environment Setup

To get started with the project, install dependencies using one of the following methods:

**Option 1: Conda (Recommended)**
Use the full environment specification:

```bash
conda env create -f environment.yml
conda activate sql_stories
```
**Option 2: pip install**

```bash
pip install -r requirements.txt
```

📦 The environment.yml includes tools for working with Jupyter, SQLite, Google Sheets, and testing — ideal for full local development.
___

## 🤝 On Generative AI Use

Generative AI tools (including models from Google and OpenAI) were used throughout this project as part of an integrated workflow — supporting code generation, documentation refinement, and idea testing. These tools accelerated development, but the logic, structure, and documentation reflect intentional, human-led design. This repository reflects a collaborative process where automation supports clarity and iteration deepens understanding.


## 📦 Licensing

This project is licensed under the [MIT License](LICENSE).</file>

---

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
