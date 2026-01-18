WITH sales AS (

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

    WHERE
        products.division <> 'test'
        AND postal_codes.postal_code <> '00000'

),

final AS (

    SELECT
        factory,
        product_id,
        product_name,
        division,
        unit_price,
        unit_cost,
        state_name,
        city,
        postal_code,
        order_id,
        customer_id,
        order_date,
        order_amount,
        gross_profit

    FROM sales

)

SELECT * FROM final
