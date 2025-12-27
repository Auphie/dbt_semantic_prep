WITH sales AS (

    SELECT * FROM {{ ref('stg_sales') }}

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        {{ dbt_utils.generate_surrogate_key(['postal_code']) }} AS postal_code_key,
        sale_id,
        order_id,
        order_date,
        ship_date,
        ship_mode,
        customer_id,
        -- country_region,
        -- city,
        -- state_province,
        postal_code,
        -- division,
        -- region,
        order_amount,
        units,
        gross_profit,
        order_cost

    FROM sales

)

SELECT * FROM final
