WITH sales AS (

    SELECT * FROM {{ source('seed', 'Candy_Sales') }}

),

renamed AS (

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

),

final AS (

    SELECT
        sale_id,
        order_id,
        order_date,
        ship_date,
        ship_date - order_date AS transit_days,
        ship_mode,
        customer_id,
        country_region,
        city,
        state_province,
        postal_code,
        division,
        region,
        product_id,
        product_name,
        order_amount,
        units,
        gross_profit,
        order_cost

    FROM renamed

)

SELECT * FROM final
