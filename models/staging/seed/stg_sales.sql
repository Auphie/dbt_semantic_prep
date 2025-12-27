WITH sales AS (

    SELECT * FROM {{ source('seed', 'Candy_Sales') }}

),

final AS (

    SELECT
        "Row ID" AS sale_id,
        "Order ID" AS order_id,
        "Order Date" AS order_date,
        "Ship Date" AS ship_date,
        "Ship Mode" AS ship_mode,
        "Customer ID" AS customer_id,
        "Country/Region" AS country_region,
        "City" AS city,
        "State/Province" AS state_province,
        "Postal Code" AS postal_code,
        "Division" AS division,
        "Region" AS region,
        "Product ID" AS product_id,
        "Product Name" AS product_name,
        "Sales" AS order_amount,
        "Units" AS units,
        "Gross Profit" AS gross_profit,
        "Cost" AS order_cost

    FROM sales

)

SELECT * FROM final
