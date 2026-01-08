# dbt_semantic_prep

This repository contains a small dbt project that prepares seed data for semantic models and demonstrates common staging, core (dimensions/facts), and marts layers.

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
│   │     ├─ Sales.sql
│   │     └─ Sales.yml
│   │
│   └─ staging/                    # Raw data from sources
│      └─ {source}/
│         ├─ _{source}__sources.yml
│         ├─ stg_seed_factories.sql
│         └─ stg_seed_factories.yml
│
├─ seeds/             #  Static data (CSV files)
│
├─ tests/             #  Data quality checks
│
├─ snapshots/         #  Slowly Changing Dimensions
│
├─ .sqlfluff                      # Linter rule settings
├─ .sqlfluffignore                # Ignore linter rule settings
├─ .gitignore                     # Ignore local/personal files
└─dbt_project.yml    -- Project configuration 
```

## Model naming convention

- Staging level: `stg_<source>_<table>` (e.g., `stg_seed_sales`)
- Core level: `dim_<name>` or `fct_<name>` (e.g., `dim_products`, `fct_sales`)
- Mart level: `{grain}_<business_name>` (e.g., `fct_daily_sales`)
- Semantic layer: PascalCase or as required by the semantic tooling (e.g., `Sales`)
- Intermediate: `int_<treatment in past verb tense>` (e.g., `int_sales_merged`)

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

## Notes
 - YAML model documentation lives next to models under `models/*/*.yml` and include `data_type` and basic `tests` for common columns.
 - If you change package dependencies, run `dbt deps` before `dbt run`.
