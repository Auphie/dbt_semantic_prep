# dbt_semantic_prep

A dbt project that demonstrates a complete semantic-layer workflow on candy sales data, from raw seeds to dimensional models and semantic definitions for both:

- dbt Semantic Layer / MetricFlow
- Snowflake Semantic Model (Cortex-style YAML and semantic SQL view examples)

This repo is set up to support a side-by-side demo narrative: **"Building the Brain: A Semantic Layer Demo (dbt vs. Snowflake)"**.

## Project Goals

- Build trustworthy dimensional models (`fct_sales`, `dim_*`) as the semantic foundation.
- Define business-friendly metrics once and reuse them consistently.
- Show how semantic definitions differ between dbt MetricFlow and Snowflake semantics.
- Provide reproducible validation steps before publishing metrics to BI/AI consumers.

## Directory Structure

```
your-dbt-project/
├─ .github/
│  └─ workflows/
│     ├─ ci_progress.yml           # Linter check and dbt build test to production
│     └─ PULL_REQUEST_TEMPLATE.md  # Pull request template
│
├─ analyses/                       # SQL for reporting/analysis (compiled, not materialized)
│
├─ macros/                         # Reusable Jinja code
│
├─ models/
│   ├─ core/                       # With the finest granularity as dimensional table format
│   │  ├─ fct_sales.sql
│   │  └─ fct_sales.yml
│   │
│   ├─ intermediate/               # Transformed, reusable logic
│   │
│   ├─ marts/                      # Final business-ready data built from `core` models
│   │  └─ {domain/subject}/
│   │  │  ├─ fct_daily_sales.sql
│   │  │  └─ fct_daily_sales.yml
│   │  └─ semantic/                # semantic views for Snowflake Cortex or dbt MetricFlow
│   │     ├─ Sales.metricflow.yml
│   │     ├─ Sales.snowflake
│   │     ├─ Sales.snowsql
│   │     ├─ semantic_dimensions_reference.md
│   │     ├─ metricflow.md
│   │     └─ time_spine.sql
│   │
│   └─ staging/                    # Raw data from sources
│      └─ {source}/
│         ├─ _{source}__sources.yml
│         ├─ stg_seed_factories.sql
│         └─ stg_seed_factories.yml
│
├─ seeds/                          #  Static data (CSV files)
│
├─ tests/                          #  Data quality checks
│
├─ snapshots/                      #  Slowly Changing Dimensions
│
├─ .sqlfluff                       # Linter rule settings
├─ .sqlfluffignore                 # Ignore linter rule settings
├─ .gitignore                      # Ignore local/personal files
└─dbt_project.yml                  # Project configuration 
```

## Model naming convention

- Staging level: `stg_<source>_<table>` (e.g., `stg_seed_sales`)
- Core level: `dim_<name>` or `fct_<name>` (e.g., `dim_products`, `fct_sales`)
- Mart level: `{grain}_<business_name>` (e.g., `fct_daily_sales`)
- Semantic layer: PascalCase or as required by the semantic tooling (e.g., `Sales`)
- Intermediate: `int_<treatment in past verb tense>` (e.g., `int_sales_merged`)
- Semantic model files:
  - MetricFlow: `<Domain>.metricflow.yml`
  - Snowflake YAML: `<Domain>.snowflake`
  - Snowflake SQL semantic view: `<Domain>.snowsql`

## Modeling flow

This example project is assuming that you use dimensional model design technique.
A clear flow from raw sources to your analytic/semantic models:

```
source tables (seeds / external sources)
  └─> staging (models/staging/stg_*)
        └─> core (models/core/ dim_*, fct_*)
              └─> marts (models/marts/ e.g. fct_daily_sales)
              └─> Semantic models (models/semantic/ e.g. Sales)

Optional: intermediate models (models/intermediate/) are used for complex transformations, and can be in any of the flow intervals.
```

## Semantic Layer Assets

### 1) dbt MetricFlow

- File: `models/marts/semantic/Sales.metricflow.yml`
- Defines:
  - Semantic models: `sales_fact`, `products_dimension`, `postal_codes_dimension`, `dates_dimension`
  - Measures (raw aggregations): e.g., `order_amount_sum`, `gross_profit_sum`, `order_count`
  - Metrics (business KPIs): e.g., `total_sales`, `profit_margin`, `avg_order_value`, `expedited_sales`
  - Saved queries for common analyses

### 2) Snowflake Semantic Definitions

- File: `models/marts/semantic/Sales.snowflake`
  - YAML-style semantic model and relationships
- File: `models/marts/semantic/Sales.snowsql`
  - Semantic SQL view example

These are aligned to actual core-model columns (`sale_id`, `order_amount`, `order_id`, `units`, `order_date`, etc.).

## Quick Start

1. Install dependencies:

```bash
dbt deps
```

2. Build models and run tests:

```bash
dbt build
```

3. Parse and validate semantic config:

```bash
dbt parse
dbt ls --resource-type semantic_model --output name
```

4. Verify model queryability/permissions (example):

```bash
dbt show --select fct_sales --limit 1
dbt show --select dim_products --limit 1
dbt show --select dim_postal_codes --limit 1
dbt show --select dim_dates --limit 1
```

## Semantic Demo Checklist (dbt vs Snowflake)

Use this before recording demos or publishing article screenshots.

### A. dbt MetricFlow checks

- Entity key alignment:
  - Foreign entity names in fact models should match primary entity names in dimensions.
- Time dimension readiness:
  - Ensure a clear primary aggregation time (`defaults.agg_time_dimension`) is set.
- Measures vs metrics:
  - Keep business logic in metrics.
  - Example business-ready metric in this repo: `expedited_sales`.
- Saved-query integrity:
  - Group-by dimensions must exist in semantic definitions and underlying models.

### B. Snowflake semantic checks

- Column mapping correctness:
  - Ensure semantic expressions match physical columns.
- Relationship correctness:
  - Confirm join keys match actual core-model keys.
- Verified query run:
  - Execute a simple `SELECT` via `dbt show` (or native Snowflake query) to confirm permissions and object accessibility.
- Cortex/AI readiness:
  - If enabling Cortex Search, include and index the intended text attributes explicitly.

## Known Compatibility Note

In this project setup (`dbt==1.10.0`), the MetricFlow time-dimension flag `type_params.is_primary: true` is not accepted by parser validation. Use `defaults.agg_time_dimension` as the compatible primary-time declaration.

## Documentation Map

- MetricFlow concepts and examples: `models/marts/semantic/metricflow.md`
- Dimension reference (copy/paste names): `models/marts/semantic/semantic_dimensions_reference.md`
- Semantic implementation source of truth: `models/marts/semantic/Sales.metricflow.yml`

## Practical Tips

- Treat `models/core/*` as the contract layer for all semantics.
- Add dbt tests to enforce key assumptions that semantic joins depend on.
- Keep semantic docs synchronized whenever dimensions or metric names change.
- Favor business-friendly metric names and labels over raw measure names in stakeholder-facing outputs.
