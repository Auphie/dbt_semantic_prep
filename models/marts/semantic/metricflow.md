# dbt MetricFlow: Key Concepts & Development Guide

## What is dbt MetricFlow?

dbt MetricFlow is a semantic layer that sits on top of your dbt models, providing a standardized way to define and query business metrics. It decouples metric definitions from their implementation, allowing analysts and applications to query metrics consistently across your entire data warehouse without needing to know the underlying SQL or model details.

**Benefits:**
- **Consistency**: Define metrics once, use them everywhere
- **Abstraction**: Non-technical users can query metrics without SQL knowledge
- **Flexibility**: Swap data warehouse backends without changing metric definitions
- **Governance**: Centralized metric definitions with version control
- **Performance**: Optimized query generation and execution

---

## Key Concepts

### 1. Semantic Models

A **semantic model** is a thin semantic layer wrapping around a dbt model. It defines:
- **Entities**: Primary and foreign keys that identify the grain of the model
- **Dimensions**: Categorical attributes used for grouping and filtering
- **Measures**: Aggregatable numeric columns that drive business metrics

```yaml
semantic_models:
  - name: sales_fact
    description: "Sales fact table with order details"
    model: ref('fct_sales')
    entities:
      - name: sale_id
        type: primary
        expr: sale_id
      - name: product_key
        type: foreign
        expr: product_key
    dimensions:
      - name: order_date
        type: time
        expr: cast(order_date as DATE)
        type_params:
          time_granularity: day
      - name: ship_mode
        type: categorical
    measures:
      - name: total_order_amount
        agg: sum
        expr: order_amount
```

### 2. Entities

Entities define the grain of your semantic model and establish relationships:

- **Primary**: Uniquely identifies the grain (e.g., `sale_id` in the sales fact table)
- **Foreign**: References other semantic models (e.g., `product_key` references the products dimension)
- **Unique**: Additional unique identifiers (e.g., `order_id` in sales)

```yaml
entities:
  - name: sale_id
    type: primary
    expr: sale_id
  - name: product_key
    type: foreign
    expr: product_key
  - name: order_id
    type: unique
    expr: order_id
```

### 3. Dimensions

Dimensions are categorical or time-based attributes used for slicing data:

**Types:**
- **categorical**: Non-numeric attributes (e.g., `ship_mode`, `state_name`)
- **time**: Temporal attributes with granularity (day, week, month, year)
- **quantitative**: Numeric attributes used for grouping (not aggregation)

```yaml
dimensions:
  - name: order_date
    type: time
    expr: cast(order_date as DATE)
    type_params:
      time_granularity: day
  - name: ship_mode
    type: categorical
  - name: transit_days
    type: quantitative
```

### 4. Measures

Measures are aggregatable numeric values that form the basis of metrics:

**Common aggregations:**
- `sum`: Sum of values
- `count`: Row count
- `count_distinct`: Distinct count of values
- `average`: Mean value
- `min`: Minimum value
- `max`: Maximum value

```yaml
measures:
  - name: total_order_amount
    description: "Total sales value of all orders"
    agg: sum
    expr: order_amount
  - name: order_count
    description: "Count of distinct orders"
    agg: count_distinct
    expr: order_id
  - name: avg_unit_price
    description: "Average selling price per unit"
    agg: average
    expr: unit_price
```

### 5. Metrics

Metrics are business KPIs built from measures and dimensions:

**Types:**

#### Simple Metrics
Direct aggregations of measures:
```yaml
metrics:
  - name: total_sales
    description: "Sum of all order amounts"
    type: simple
    label: Total Sales
    type_params:
      measure: total_order_amount
```

#### Derived Metrics
Calculations combining multiple metrics:
```yaml
metrics:
  - name: average_order_value
    description: "Average value per order"
    type: derived
    label: Average Order Value
    type_params:
      expr: total_sales / order_count
      metrics:
        - total_sales
        - order_count
```

#### Ratio Metrics
Compare two measures:
```yaml
metrics:
  - name: profit_margin
    type: ratio
    label: Profit Margin
    type_params:
      numerator:
        name: profit_measure
        filter: gross_profit > 0
      denominator:
        name: sales_measure
```

#### Cumulative Metrics
Running totals over time windows:
```yaml
metrics:
  - name: ytd_sales
    type: cumulative
    label: Year-to-Date Sales
    type_params:
      measure: total_order_amount
      window: 1 year
```

### 6. Saved Queries

Pre-built query templates for common analyses, combining specific metrics and group-by dimensions:

```yaml
saved_queries:
  - name: daily_sales_summary
    description: "Daily sales summary by product division and geography"
    query_params:
      metrics:
        - total_sales
        - expedited_sales
        - total_profit
        - order_count
      group_by:
        - TimeDimension('sales_fact__order_date', 'day')
        - Dimension('products_dimension__division')
        - Dimension('postal_codes_dimension__state_name')
```

---

## Development Workflow

### Step 1: Understand Your Data Model

Review your core dbt models and identify:
- Grain and primary keys of each model
- Foreign key relationships
- Key dimensions and measures

In our project:
- **fct_sales**: Fact table at sales transaction grain
- **dim_products**: Product attributes and pricing
- **dim_postal_codes**: Geographic attributes
- **dim_dates**: Calendar dimensions

### Step 2: Create Semantic Models

Wrap each core model with a semantic model definition:

```yaml
semantic_models:
  - name: sales_fact
    description: "Sales fact table"
    model: ref('fct_sales')
    
    # Define the grain and relationships
    entities:
      - name: sale_id
        type: primary
        expr: sale_id
      - name: product_key
        type: foreign
        expr: product_key
    
    # Categorical and time dimensions
    dimensions:
      - name: order_date
        type: time
        expr: cast(order_date as DATE)
        type_params:
          time_granularity: day
    
    # Aggregatable measures
    measures:
      - name: total_sales
        agg: sum
        expr: order_amount
```

### Step 3: Define Metrics

Create business-ready metrics from your measures:

```yaml
metrics:
  - name: total_sales
    type: simple
    type_params:
      measure: total_sales
  
  - name: average_order_value
    type: derived
    type_params:
      expr: total_sales / order_count
      metrics:
        - total_sales
        - order_count
```

### Step 4: Create Saved Queries

Build pre-defined queries for common analyses:

```yaml
saved_queries:
  - name: sales_by_region
    query_params:
      metrics:
        - total_sales
        - profit_margin
      group_by:
        - Dimension('postal_codes_dimension__state_name')
```

### Step 5: Test & Validate

```bash
# Validate MetricFlow configuration
dbt parse

# Build and run
dbt build

# Query metrics (once integrated with MetricFlow CLI)
mf query --metric total_sales --group-by order_date
```

---

## Best Practices

### 1. Naming Conventions

- **Semantic models**: `{entity_type}_{grain}` (e.g., `sales_fact`, `products_dimension`)
- **Entities**: Use the actual column name (e.g., `sale_id`, `product_key`)
- **Dimensions**: Descriptive names (e.g., `order_date`, `state_name`)
- **Measures**: `{aggregation}_{metric_name}` (e.g., `total_sales`, `avg_unit_price`)
- **Metrics**: Business-friendly names (e.g., `total_sales`, `average_order_value`)

### 2. Dimension Naming in Queries

When referencing dimensions in metrics or saved queries, use:
```
{semantic_model}__{dimension_name}
```

Examples:
- `sales_fact__order_date`
- `postal_codes_dimension__state_name`
- `products_dimension__division`

### 3. Time Dimensions

Always define time dimensions with appropriate granularity:

```yaml
dimensions:
  - name: order_date
    type: time
    expr: cast(order_date as DATE)
    type_params:
      time_granularity: day
```

Supported granularities: `day`, `week`, `month`, `quarter`, `year`

### 4. Composite Dimensions

Create derived dimensions for clarity:

```yaml
dimensions:
  - name: geography
    type: categorical
    expr: concat(city, ', ', state_id)
```

### 5. Measure Specifications

Use explicit `expr` for clarity:

```yaml
measures:
  - name: customer_count
    agg: count_distinct
    expr: customer_id  # Be explicit about what you're counting
```

### 6. Metric Filters

Apply business logic at the metric level:

```yaml
metrics:
  - name: expedited_sales
    type: simple
    label: Expedited Sales
    type_params:
      measure: order_amount_sum
    filter: |
      {{ Dimension('sales_fact__ship_mode') }} in ('Express', 'Overnight')
```

### 7. Documentation

Document all semantic models, dimensions, and metrics:

```yaml
semantic_models:
  - name: sales_fact
    description: |
      Sales fact table at the transaction grain.
      One row per sale with order details, financials, and fulfillment info.
```

---

## Common Patterns in This Project

### Pattern 1: Fact Table with Dimensional Joins

The `Sales.metricflow.yml` file demonstrates this pattern:
- Central fact table (`fct_sales`) with foreign keys
- Dimension tables (`dim_products`, `dim_postal_codes`, `dim_dates`)
- Cross-dimensional metrics and analyses

### Pattern 2: Derived Geographic Dimension

```yaml
dimensions:
  - name: geography
    type: categorical
    expr: concat(city, ', ', state_id)  # Composite dimension
```

### Pattern 3: Time-Based Analysis

Multiple time dimensions enable flexible temporal analysis:

```yaml
dimensions:
  - name: order_date
    type: time
    expr: cast(order_date as DATE)
    type_params:
      time_granularity: day
  - name: ship_date
    type: time
    expr: cast(ship_date as DATE)
    type_params:
      time_granularity: day
```

### Pattern 4: Financial Metrics

Derived metrics for business KPIs:

```yaml
metrics:
  - name: profit_margin
    type: derived
    type_params:
      expr: (total_profit / total_sales) * 100
      metrics:
        - total_profit
        - total_sales
```

---

## Querying Metrics

### Via dbt Cloud / MetricFlow CLI

```bash
# Query a metric with grouping
mf query \
  --metric total_sales \
  --group-by order_date \
  --where "{{ Dimension('postal_codes_dimension__state_name') }} = 'California'"

# Run a saved query
mf query --saved-query daily_sales_summary
```

### Via SQL (with MetricFlow)

```sql
SELECT
  DATE_TRUNC('day', metric_time) AS order_date,
  division,
  state_name,
  total_sales,
  expedited_sales,
  total_profit,
  order_count
FROM {{ metrics(
  metrics=['total_sales', 'expedited_sales', 'total_profit', 'order_count'],
  group_by=['order_date', 'division', 'state_name']
) }}
```

---

## File Structure

```
models/marts/semantic/
├── Sales.metricflow.yml     # Main MetricFlow semantic layer
├── Sales.snowsql            # Legacy Snowflake semantic view
├── Sales.snowflake          # Legacy Snowflake semantic view
└── metricflow.md            # This documentation
```

---

## Resources

- [dbt MetricFlow Documentation](https://docs.getdbt.com/docs/build/sl-getting-started)
- [MetricFlow CLI Reference](https://docs.getdbt.com/docs/build/sl-command-line)
- [jaffle-sl-template Example](https://github.com/dbt-labs/jaffle-sl-template)
- [MetricFlow Best Practices](https://docs.getdbt.com/docs/build/semantic-layer-best-practices)

---

## Quick Reference

### Dimension Reference in Saved Queries
```
Dimension('semantic_model__dimension_name')
TimeDimension('semantic_model__time_dimension', 'granularity')
```

### Common Aggregations
|    Aggregation   |             Use Case            |
|------------------|---------------------------------|
| `sum`            | Total revenue, total quantity   |
| `count`          | Row count                       |
| `count_distinct` | Unique customers, unique orders |
| `average`        | Average price, average units    |
| `min` / `max`    | Minimum/maximum values          |

### Metric Types Quick Reference
|     Type     |             Purpose            |       Example     |
|--------------|--------------------------------|-------------------|
| `simple`     | Direct measure aggregation     | `total_sales`     |
| `derived`    | Calculation from other metrics | `avg_order_value` |
| `ratio`      | Compare two measures           | `profit_margin`   |
| `cumulative` | Running total over time        | `ytd_sales`       |

---

## Next Steps

1. **Review** the existing `Sales.metricflow.yml` to understand structure
2. **Extend** with additional semantic models as your data layer grows
3. **Add** more derived metrics for business KPIs
4. **Create** saved queries for common analyses
5. **Integrate** with downstream tools (dbt Cloud, BI platforms, APIs)
