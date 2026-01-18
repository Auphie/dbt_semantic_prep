-- The intermediate source model has been curated to have clean sales data.
-- This model demonstrates the use of the centralized intermediate source and macro to get
-- sales metrics in different categories with the same aggregation logic.
WITH sales AS (

    SELECT * FROM {{ ref('int_sales') }}

),

-- Input different states and attributes onto the macro to get state specific sales metrics.
-- The tranformation and aggregation logic is handled in the macro.

us_yearly_sales AS (

    {{ aggregate_semantic_metrics(
        input_name='sales',
        dimensions=['factory'],
        time_dimension='year',
        filters=["order_id like 'US-%'"],
        unique_metrics=['order_id', 'customer_id'],
        cummulative_metrics=['order_amount', 'gross_profit'],
        ratio_metrics=[]
    ) }}

),

final AS (

    SELECT
        year AS sales_year,
        factory,
        -- You can add more dimensions here as needed for your analysis or reporting. 
        order_id_count AS yearly_total_us_orders,
        customer_id_count AS yearly_unique_us_customers,
        order_amount AS yearly_total_us_sales,
        gross_profit AS yearly_total_us_gross_profit

    FROM us_yearly_sales

)

SELECT * FROM final
