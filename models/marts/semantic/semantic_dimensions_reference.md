# MetricFlow Semantic Dimensions Reference

Quick lookup guide for all available dimensions in the semantic layer. Use these exact names when building saved queries and metric filters.

---

## Naming Convention

All dimension references follow this pattern:

```
{semantic_model_name}__{dimension_name}
```

For **time dimensions**, also specify granularity:
```
TimeDimension('{semantic_model_name}__{dimension_name}', '{granularity}')
```

For **categorical/quantitative dimensions**:
```
Dimension('{semantic_model_name}__{dimension_name}')
```

---

## Semantic Model: `sales_fact`

**Source Table**: `fct_sales`  
**Grain**: Transaction level (one row per sale)  
**Primary Key**: `sale_id`

### Time Dimensions

#### `sales_fact__order_date`
- **Source Column**: `order_date`
- **Type**: TimeDimension
- **Granularities**: day, week, month, quarter, year
- **Use Case**: Order placement analysis, primary time dimension for all temporal queries

#### `sales_fact__ship_date`
- **Source Column**: `ship_date`
- **Type**: TimeDimension
- **Granularities**: day, week, month, quarter, year
- **Use Case**: Fulfillment and shipping analysis, order delivery timeline tracking

**Usage Examples**:
```yaml
# Daily grouping
- TimeDimension('sales_fact__order_date', 'day')

# Monthly trend analysis
- TimeDimension('sales_fact__order_date', 'month')

# Year-over-year comparison
- TimeDimension('sales_fact__ship_date', 'year')
```

### Categorical Dimensions

| Reference | Source Column | Type | Description |
|-----------|---------------|------|-------------|
| `sales_fact__customer_id` | `customer_id` | Dimension (categorical) | Customer identifier for customer-level grouping |
| `sales_fact__ship_mode` | `ship_mode` | Dimension (categorical) | Shipping method (Standard, Express, Overnight, etc.) |

**Usage Examples**:
```yaml
# Group by shipping method
- Dimension('sales_fact__ship_mode')

# Filter by customer
where: "{{ Dimension('sales_fact__customer_id') }} = 'CUST123'"
```

### Quantitative Dimensions

| Reference | Source Column | Type | Description |
|-----------|---------------|------|-------------|
| `sales_fact__transit_days` | `transit_days` | Dimension (quantitative) | Days from order to ship; used for grouping/trend analysis |

**Usage Examples**:
```yaml
# Group by transit time buckets
- Dimension('sales_fact__transit_days')
```

---

## Semantic Model: `products_dimension`

**Source Table**: `dim_products`  
**Grain**: Product level (one row per product)  
**Primary Key**: `product_key`

### Categorical Dimensions

| Reference | Source Column | Type | Description |
|-----------|---------------|------|-------------|
| `products_dimension__product_name` | `product_name` | Dimension | Product display name |
| `products_dimension__category` | `category` | Dimension | High-level product category |
| `products_dimension__subcategory` | `subcategory` | Dimension | Sub-classification within category |
| `products_dimension__division` | `division` | Dimension | Business division responsible for product |
| `products_dimension__factory` | `factory` | Dimension | Manufacturing facility name |
| `products_dimension__factory_location` | Computed | Dimension | Composite: Factory name with coordinates (e.g., "Factory A (40.71, -74.01)") |

**Usage Examples**:
```yaml
# Product category analysis
- Dimension('products_dimension__category')

# Filter by specific division
where: "{{ Dimension('products_dimension__division') }} = 'Electronics'"

# Geographic factory analysis
group_by:
  - Dimension('products_dimension__factory_location')
```

---

## Semantic Model: `postal_codes_dimension`

**Source Table**: `dim_postal_codes`  
**Grain**: Postal code level (one row per zip code)  
**Primary Key**: `postal_code_key`

### Categorical Dimensions

| Reference | Source Column | Type | Description |
|-----------|---------------|------|-------------|
| `postal_codes_dimension__postal_code` | `postal_code` | Dimension | 5-digit postal code |
| `postal_codes_dimension__city` | `city` | Dimension | City name |
| `postal_codes_dimension__state_id` | `state_id` | Dimension | State abbreviation (CA, NY, TX, etc.) |
| `postal_codes_dimension__state_name` | `state_name` | Dimension | Full state name (California, New York, Texas, etc.) |
| `postal_codes_dimension__county_name` | `county_name` | Dimension | County name for sub-state analysis |
| `postal_codes_dimension__county_fips` | `county_fips` | Dimension | FIPS code for standardized county identification |
| `postal_codes_dimension__timezone` | `timezone` | Dimension | IANA timezone identifier (e.g., America/Los_Angeles) |
| `postal_codes_dimension__geography` | Computed | Dimension | Composite: City and state (e.g., "San Francisco, CA") |
| `postal_codes_dimension__region` | Computed | Dimension | Geographic region derived from state (West, South, Northeast, Midwest, Other) |

**Usage Examples**:
```yaml
# State-level analysis
- Dimension('postal_codes_dimension__state_name')

# Regional breakdown (West, South, Northeast, Midwest)
- Dimension('postal_codes_dimension__region')

# City-level detail
- Dimension('postal_codes_dimension__city')

# Geographic grouping
- Dimension('postal_codes_dimension__geography')

# Filter by region
where: "{{ Dimension('postal_codes_dimension__region') }} = 'West'"

# Filter by state
where: "{{ Dimension('postal_codes_dimension__state_id') }} IN ('CA', 'OR', 'WA')"
```

---

## Semantic Model: `dates_dimension`

**Source Table**: `dim_dates`  
**Grain**: Calendar day level (one row per day)  
**Primary Key**: `date_key`

### Categorical Dimensions

| Reference | Source Column | Type | Description |
|-----------|---------------|------|-------------|
| `dates_dimension__calendar_date` | `date_key` | Dimension | Full date value |
| `dates_dimension__calendar_year` | `date_year` | Dimension | Calendar year (YYYY) |
| `dates_dimension__calendar_month` | `date_month` | Dimension | Calendar month (1-12) |
| `dates_dimension__month_name` | Computed | Dimension | Month name (January, February, etc.) |
| `dates_dimension__day_of_month` | `day_of_month` | Dimension | Day of month (1-31) |
| `dates_dimension__day_name` | `day_name` | Dimension | Abbreviated day name (Mon, Tue, Wed, etc.) |
| `dates_dimension__full_day_name` | `full_day_name` | Dimension | Full day name (Monday, Tuesday, etc.) |
| `dates_dimension__week_of_year` | `week_of_year` | Dimension | ISO week number (1-53) |
| `dates_dimension__day_of_year` | `day_of_year` | Dimension | Day of year (1-366); useful for trend analysis |
| `dates_dimension__year_month` | Computed | Dimension | Composite: Year-month format (YYYY-MM) |

**Usage Examples**:
```yaml
# Year-over-year comparison
- Dimension('dates_dimension__calendar_year')

# Monthly aggregation
- Dimension('dates_dimension__calendar_month')

# Day of week pattern analysis
- Dimension('dates_dimension__day_name')

# Weekly report grouping
- Dimension('dates_dimension__week_of_year')

# Year-month grouping
- Dimension('dates_dimension__year_month')

# Filter to specific year
where: "{{ Dimension('dates_dimension__calendar_year') }} = 2024"

# Filter to weekdays only
where: "{{ Dimension('dates_dimension__day_name') }} NOT IN ('Sat', 'Sun')"
```

---

## Complete Example: Building a Saved Query

Here's how to use these dimension references in a saved query:

```yaml
saved_queries:
  - name: regional_monthly_sales
    description: "Monthly sales by region and product category"
    query_params:
      metrics:
        - total_sales
        - total_profit
        - profit_margin
        - order_count
      group_by:
        # Time dimension with monthly granularity
        - TimeDimension('sales_fact__order_date', 'month')
        
        # Geographic dimensions
        - Dimension('postal_codes_dimension__region')
        - Dimension('postal_codes_dimension__state_name')
        
        # Product dimensions
        - Dimension('products_dimension__category')
```

---

## Quick Reference Table

| Semantic Model | Count | Primary Use |
|---|---|---|
| `sales_fact` | 5 dimensions | Transaction-level analysis (orders, revenue, fulfillment) |
| `products_dimension` | 6 dimensions | Product performance and categorization |
| `postal_codes_dimension` | 9 dimensions | Geographic analysis and regional reporting |
| `dates_dimension` | 10 dimensions | Time-series analysis and calendar grouping |
| **TOTAL** | **30 dimensions** | Complete business analytics |

---

## Filtering with Dimensions

All dimensions can be used in metric filters using the `where` clause:

```yaml
metrics:
  - name: western_region_sales
    type: simple
    type_params:
      measure: total_sales
    filter: |
      {{ Dimension('postal_codes_dimension__region') }} = 'West'

  - name: q4_orders
    type: simple
    type_params:
      measure: order_count
    filter: |
      {{ Dimension('dates_dimension__calendar_month') }} >= 10
```

---

## Tips & Best Practices

1. **Always use the exact reference name** - Copy-paste from this guide to avoid typos
2. **TimeDimensions need granularity** - Don't forget the second parameter: `TimeDimension('sales_fact__order_date', 'month')`
3. **Composite dimensions save time** - Use `postal_codes_dimension__geography` instead of grouping by city and state separately
4. **Regional analysis** - Use `postal_codes_dimension__region` for quick regional summaries
5. **Year-month grouping** - Use `dates_dimension__year_month` for consistent month-level reporting

---

## Updating This Reference

When new dimensions are added to semantic models, update this file to keep the reference current. The structure should match the actual semantic model definitions in `Sales.metricflow.yml`.

**Last Updated**: January 14, 2026  
**Dimensions Defined**: 30  
**Semantic Models**: 4
