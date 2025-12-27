WITH products AS (

    SELECT * FROM {{ source('seed', 'Candy_Products') }}

),

final AS (

    SELECT
        "Product ID" AS product_id,
        "Product Name" AS product_name,
        "Division" AS division,
        "Factory" AS factory,
        "Unit Price" AS unit_price,
        "Unit Cost" AS unit_cost

    FROM products

)

SELECT * FROM final
