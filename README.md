<p align="center">
  <img src="repo_files/dark_logo_banner.png" width="1000"/>
  <br>
  <em>SQL Training Simulation & Skills Builder</em>
</p>

<p align="center">
  <img alt="MIT License" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="Status" src="https://img.shields.io/badge/status-alpha-lightgrey">
  <img alt="Version" src="https://img.shields.io/badge/version-v0.1.0-blueviolet">
</p>

## 📚 SQL Stories

SQL Stories is a simulation-based training suite designed to help data professionals grow their analytical skills through realistic business scenarios. Each "story" is a self-contained project with:

- A business context and stakeholder brief
- Clean or messy synthetic data (via our generator)
- Guided SQL exercises or open-ended diagnostic challenges
- Optional dashboards, notebooks, or follow-up prompts

Whether you're a beginner learning joins or a practitioner refining your storytelling with SQL, this repo offers a narrative-driven way to build confidence and context.

Each scenario is modular and remixable. You can treat them as:
- SQL interview prep modules
- Portfolio-ready case studies
- Practice environments for real-world patterns

> 🧠 Inspired by real analyst tasks, tuned for solo practice, and built to scale with your growth.

## 🧩 TL;DR

- This repo contains SQL projects that simulate real business problems
- [Scenario 5](story_05_vp_request) is included as a full end-to-end workflow demo
- All data is generated from [this repo](https://github.com/G-Schumacher44/ecom_sales_data_generator)
- Each story lives in its own folder and includes markdown briefs + SQL
- Scenarios use clean or messy data to simulate real-life friction
- GPT-4 was used to generate each scenario's narrative
- Great for practicing joins, cohorts, KPIs, and data storytelling

<details>
<summary>📌 Portfolio Highlight</summary>

If you're reviewing this repo as part of a hiring process, start here:

- [`story_05_vp_request/`](story_05_vp_request/): Full analysis pipeline — raw data → SQL views → notebook → dashboard
- [`Executive_Retail_Returns_Report.ipynb`](story_05_vp_request/reports/Executive_Retail_Returns_Report.ipynb): Annotated notebook with visuals, commentary, and insights
- [`Sales_Diagnostic.pdf`](story_05_vp_request/reports/Sales_Diagnostic.pdf): Final deliverable simulating a VP-level presentation

This scenario reflects a real-world analyst workflow: stakeholder request, diagnostic framing, KPI development, cohort analysis, and visual storytelling.

</details>

## 📐 What’s Included

- [`db_builder.zip`](ecom_data_gen_output/db_builder.zip) — CSVs + schema script to build the SQLite database  
- [`ecom_retailer.db`](ecom_retailer.db) — a fully built SQLite database  
- Five prebuilt SQL scenarios (difficulty levels 1–5)  
  - Scenario 5 is a complete workflow demo  
    - Includes deliverables, exported datasets, SQL queries, and Python notebooks  
- [`storycrafting.md`](storycrafting.md)— internal design doc on how stories are framed and built

> 🚫 Not included in this repo: the data generator itself — that's housed in [`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator).


## 🧭 Orientation & Getting Started

<details>
<summary><strong>🧠 Notes from the Dev Team</strong></summary>
<br>

**Task and Purpose**

This project was born out of a need to go beyond surface-level SQL practice. It started as a personal challenge — to create a learning environment that mimicked real work: ambiguous prompts, messy data, and evolving business logic. The online resources available felt too clean, too isolated, or too abstract.

That quest led to building a custom data generator (now maintained in the [`ecom_sales_data_generator`](https://github.com/G-Schumacher44/ecom_sales_data_generator) repo) and structuring a storytelling system that could scale.

Along the way, it became clear that this system — combining simulated data, scenario design, and AI tooling — could benefit others too. 

</details>

<details>
<summary><strong>🫆 Version Release Notes</strong></summary>

**v0.1.0 — Alpha Launch**
- Includes fully built database and `db_builder.zip`
- Five scenarios with ascending complexity (CR 1–5)
- Scenario 5 demo includes full workflow: deliverables, notebooks, exports
- AI-assisted design used for scenario crafting, QA, and documentation
- Includes full storycrafting methodology doc

**Planned for v0.2.0**
- More SQL stories (CR 6 and beyond)
- Richer simulation data: enhanced return logic, behavior, and join depth
- Cohort-specific mess settings (per table)
- Optional notebook integrations and user prompts
- Scenario templating support and QA checklists

> Targeting alignment with `ecom_sales_data_generator` enhancements to support layered realism

</details>

<details>
<summary>⚙️ Project Structure</summary>

```
sql_stories/
├── ecom_data_gen_output/
│   └── db_builder.zip                  # Zipped data + schema loader (CSVs + SQL)
│
├── repo_files/
│   └── dark_logo_banner.png           # Project header image or branding
│
├── story_01_inventory_accuracy/
│   └── sceanrio_01_inventory_accuracy.md
│
├── story_02_customer_retention_snapshot/
│   └── scenari_02_retention_snapshot.md
│
├── story_03_product_profitability_review/
│   └── scenario_03_product_profit_review.md
│
├── story_04_operational_impact_analysis/
│   └── scenario_04_ops_impact_analysis.md
│
├── story_05_vp_request/
│   ├── output_data/                   # Exports or derived data
│   ├── python_scripts/                # Jupyter or .py files used in the demo
│   ├── reports/                       # Final deliverables (PDFs, slides, etc.)
│   ├── sql_sessions/                  # SQL queries and sessions
│   └── scenario_05_vp_request.md      # Business framing for the scenario
│
├── .gitignore                         # Standard ignore rules
├── ecom_retailer.db                   # Pre-built SQLite database
├── environment.yml                    # Conda or pip environment spec
├── README.md                          # Main project introduction
├── requirements.txt                   # Python dependency list
└── storycrafting.md                   # Internal design + methodology doc
```

</details>

<details>

<summary>💡 Sample AI Prompt for Scenario Design</summary>

Use this data generator alongside AI to create realistic business analysis scenarios. For the best results, upload your generated database to enable context-aware assistance.

```text
I have a synthetic e-commerce dataset with tables for orders, returns, customers, and products. 
Please help me design a business scenario that reflects a real-world problem an analyst might face.

Include a short background, 2–3 guiding business questions, and examples of SQL queries that could help answer them.
```

</details>

___

## 🔗 Ready to Explore?

Start with **[Story 5: VP Sales Diagnostic](story_05_vp_request)** to see a full workflow — from stakeholder framing to SQL analysis, deliverables, and dashboards.

Or explore the simulation step-by-step:
- Open [`ecom_retailer.db`](ecom_retailer.db) in your SQLite viewer of choice
- Review [`db_builder.zip`](ecom_data_gen_output/db_builder.zip) to rebuild the database from CSV
- Read through [`storycrafting.md`](storycrafting.md) for how scenarios are built and framed
- Try enhancing an existing scenario — or writing your own from scratch

> Every folder is a sandbox. Fork, remix, and extend as you grow your SQL fluency.

Need ideas? Run the [sample AI prompt](sample_ai_prompt.md) with your own data for instant scenario generation.

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

Generative AI tools (Gemini 2.5-PRO, ChatGPT 4o - 4.1) were used throughout this project as part of an integrated workflow — supporting code generation, documentation refinement, and idea testing. These tools accelerated development, but the logic, structure, and documentation reflect intentional, human-led design. This repository reflects a collaborative process: where automation supports clarity, and iteration deepens understanding.

---

## 📦 Licensing

This project is licensed under the [MIT License](LICENSE).</file>
