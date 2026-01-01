WITH products AS (

    SELECT * FROM {{ ref('stg_seed_products') }}

),

factories AS (

    SELECT * FROM {{ ref('stg_seed_factories') }}

),

add_factory_info AS (

    SELECT
        products.*,
        factories.latitude AS factory_latitude,
        factories.longitude AS factory_longitude

    FROM products
    LEFT JOIN factories
        ON products.factory = factories.factory

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['product_id']) }} AS product_key,
        product_id,
        product_name,
        division,
        factory,
        factory_latitude,
        factory_longitude,
        unit_price,
        unit_cost

    FROM add_factory_info

)

SELECT * FROM final
