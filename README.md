# dbt_semantic_prep

This repository contains a small dbt project that prepares seed data for semantic metrics and demonstrates common staging, core (dimensions/facts), and marts layers.

## Project layout

 - `seeds/` — CSV seed data used as raw source inputs.
 - `models/staging` — lightweight transformations from seeds/sources into canonical column names.
 - `models/core` — preserve the graniuity of the source data, but integrate/adjust it into dimensional table format. (surrogate keys, joins).
 - `models/marts` — making calculated fact models from `core` for analytics, departments or project base (surrogate keys, joins).
 - `models/core` — preserve the granularity of the source data and integrate/adjust it into dimensional table format (surrogate keys, joins).
 - `models/marts` — business-facing aggregates and marts built from `core` for analytics and reporting.
 - `models/semantic` — semantic views for Snowflake Cortex or dbt MetricFlow.

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

## Model naming convention

- Staging level: `stg_<source>_<table>` (e.g., `stg_seed_sales`)
- Core level: `dim_<name>` or `fct_<name>` (e.g., `dim_products`, `fct_sales`)
- Mart level: `{grain}_<business_name>` (e.g., `fct_daily_sales`)
- Semantic layer: PascalCase or as required by the semantic tooling (e.g., `Sales`)
- Intermediate: `int_<treatment in past verb tense>` (e.g., `int_payment_merged`)

Notes
 - YAML model documentation lives next to models under `models/*/*.yml` and include `data_type` and basic `tests` for common columns.
 - If you change package dependencies, run `dbt deps` before `dbt run`.
