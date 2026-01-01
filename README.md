# dbt_semantic_prep

This repository contains a small dbt project that prepares seed data for semantic metrics and demonstrates common staging, core (dimensions/facts), and marts layers.

Project layout
 - `models/staging` — lightweight transformations from seeds/sources into canonical column names.
 - `models/core` — dimensions and fact tables (surrogate keys, joins).
 - `models/marts` — marts for analytics, departments or project base.
 - `models/semantic` — semantic views for Snowflake or dbt MetricFlow.
 - `seeds/` — CSV seed data used as raw source inputs.

Modeling flow
[Source Tables] 
     ↓
[stg_orders, stg_seed_products, stg_customers]        -- staging
     ↓
[dim_products, fct_sales]                        -- core
     ↓
[daily_sales_metrics, unit_sales]                -- mart
     ↓
[Sales, Revenues]                                -- semantic

[int_order_source_merged, int_store_trimmed]     -- intermediate

Model naming convension
 - staging: stg_<source>_<table_name>
 - core: dim_, fct_
 - mart: {grain level}_business_idea
 - semantic: (Uppercase) Business_idea
 - intermediate: int_{treatment in past verb tense}

Notes
 - YAML model documentation lives next to models under `models/*/*.yml` and include `data_type` and basic `tests` for common columns.
 - If you change package dependencies, run `dbt deps` before `dbt run`.
