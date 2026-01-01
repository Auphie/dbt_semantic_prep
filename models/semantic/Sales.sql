WITH big_table AS (

    SELECT
        {{ dbt_utils.star(from=ref('fct_sales'), except=["product_key", "postal_code_key"]) }},
        {{ dbt_utils.star(from=ref('dim_products'), except=["product_key"]) }},
        {{ dbt_utils.star(from=ref('dim_dates'), except=["date_key"]) }},
        {{ dbt_utils.star(from=ref('dim_postal_codes'), except=["postal_code_key"]) }}

    FROM {{ ref('fct_sales') }} AS sales
    LEFT JOIN {{ ref('dim_products') }} AS products
        ON sales.product_key = products.product_key
    LEFT JOIN {{ ref('dim_dates') }} AS dates
        ON sales.order_date = dates.date_key
    LEFT JOIN {{ ref('dim_postal_codes') }} AS postal_codes
        ON sales.postal_code_key = postal_codes.postal_code_key

),

final AS (

    {{ aggregate_semantic_metrics(
        input_name='big_table',
        dimensions=['factory'],
        time_dimension="DATE_PART('year', order_date) = 2021",
        filters=["state_name = 'California'"],
        unique_metrics=['order_id', 'customer_id'],
        cummulative_metrics=['order_amount', 'gross_profit'],
        ratio_metrics=[]
    ) }}

)

SELECT * FROM final
