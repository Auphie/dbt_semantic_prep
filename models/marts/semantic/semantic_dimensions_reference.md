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
#### `sales_fact__customer_id`
- **Source Column**: `customer_id`
- **Type**: Dimension (categorical)
- **Description**: Customer identifier for customer-level grouping

#### `sales_fact__ship_mode`
- **Source Column**: `ship_mode`
- **Type**: Dimension (categorical)
- **Description**: Shipping method (Standard, Express, Overnight, etc.)

**Usage Examples**:
```yaml
# Group by shipping method
- Dimension('sales_fact__ship_mode')

# Filter by customer
where: "{{ Dimension('sales_fact__customer_id') }} = 'CUST123'"
```

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
#### `products_dimension__product_name`
- **Source Column**: `product_name`
- **Type**: Dimension
- **Description**: Product display name

#### `products_dimension__category`
- **Source Column**: `category`
- **Type**: Dimension
- **Description**: High-level product category

#### `products_dimension__subcategory`
- **Source Column**: `subcategory`
- **Type**: Dimension
- **Description**: Sub-classification within category

#### `products_dimension__division`
- **Source Column**: `division`
- **Type**: Dimension
- **Description**: Business division responsible for product

#### `products_dimension__factory`
- **Source Column**: `factory`
- **Type**: Dimension
- **Description**: Manufacturing facility name

#### `products_dimension__factory_location`
- **Source Column**: `Computed`
- **Type**: Dimension
- **Description**: Composite: Factory name with coordinates (e.g., "Factory A (40.71, -74.01)")

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
#### `postal_codes_dimension__postal_code`
- **Source Column**: `postal_code`
- **Type**: Dimension
- **Description**: 5-digit postal code

#### `postal_codes_dimension__city`
- **Source Column**: `city`
- **Type**: Dimension
- **Description**: City name

#### `postal_codes_dimension__state_id`
- **Source Column**: `state_id`
- **Type**: Dimension
- **Description**: State abbreviation (CA, NY, TX, etc.)

#### `postal_codes_dimension__state_name`
- **Source Column**: `state_name`
- **Type**: Dimension
- **Description**: Full state name (California, New York, Texas, etc.)

#### `postal_codes_dimension__county_name`
- **Source Column**: `county_name`
- **Type**: Dimension
- **Description**: County name for sub-state analysis

#### `postal_codes_dimension__county_fips`
- **Source Column**: `county_fips`
- **Type**: Dimension
- **Description**: FIPS code for standardized county identification

#### `postal_codes_dimension__timezone`
- **Source Column**: `timezone`
- **Type**: Dimension
- **Description**: IANA timezone identifier (e.g., America/Los_Angeles)

#### `postal_codes_dimension__geography`
- **Source Column**: `Computed`
- **Type**: Dimension
- **Description**: Composite: City and state (e.g., "San Francisco, CA")

#### `postal_codes_dimension__region`
- **Source Column**: `Computed`
- **Type**: Dimension
- **Description**: Geographic region derived from state (West, South, Northeast, Midwest, Other)

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
#### `dates_dimension__calendar_date`
- **Source Column**: `date_key`
- **Type**: Dimension
Description: Full date value

#### `dates_dimension__calendar_year`
- **Source Column**: `date_year`
- **Type**: Dimension
- **Description**: Calendar year (YYYY)

#### `dates_dimension__calendar_month`
- **Source Column**: `date_month`
- **Type**: Dimension
- **Description**: Calendar month (1–12)

#### `dates_dimension__month_name`
- **Source Column**: `Computed`
- **Type**: Dimension
- **Description**: Month name (January, February, etc.)

#### `dates_dimension__day_of_month`
- **Source Column**: `day_of_month`
- **Type**: Dimension
- **Description**: Day of month (1–31)

#### `dates_dimension__day_name`
- **Source Column**: `day_name`
- **Type**: Dimension
- **Description**: Abbreviated day name (Mon, Tue, Wed, etc.)

#### `dates_dimension__full_day_name`
- **Source Column**: `full_day_name`
- **Description**: Dimension
Description: Full day name (Monday, Tuesday, etc.)

#### `dates_dimension__week_of_year`
- **Source Column**: `week_of_year`
- **Type**: Dimension
- **Description**: ISO week number (1–53)

#### `dates_dimension__day_of_year`
- **Source Column**: `day_of_year`
- **Type**: Dimension
- **Description**: Day of year (1–366); useful for trend analysis

#### `dates_dimension__year_month`
- **Source Column**: `Computed`
- **Type**: Dimension
- **Description**: Composite: Year-month format (YYYY-MM)

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
