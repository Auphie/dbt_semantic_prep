-- The intermediate source model has been curated to have clean sales data.
-- This model demonstrates the use of the centralized intermediate source and macro to get
-- sales metrics in different categories with the same aggregation logic.
WITH sales AS (

    SELECT * FROM {{ ref('int_sales') }}

),

-- Input different states and attributes onto the macro to get state specific sales metrics.
-- The tranformation and aggregation logic is handled in the macro.

us_daily_sales AS (

    {{ aggregate_semantic_metrics(
        input_name='sales',
        dimensions=['factory'],
        time_dimension='day',
        filters=["order_id like 'US-%'"],
        unique_metrics=['order_id', 'customer_id'],
        cummulative_metrics=['order_amount', 'gross_profit'],
        ratio_metrics=[]
    ) }}

),

final AS (

    SELECT
        day AS sales_date,
        factory,
        -- You can add more dimensions here as needed for your analysis or reporting. 
        order_id_count AS daily_total_us_orders,
        customer_id_count AS daily_unique_us_customers,
        order_amount AS daily_total_us_sales,
        gross_profit AS daily_total_us_gross_profit

    FROM us_daily_sales

)

SELECT * FROM final
