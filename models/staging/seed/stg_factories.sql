WITH factories AS (

    SELECT * FROM {{ source('seed', 'Candy_Factories') }}

),

final AS (

    SELECT
        "Factory" AS factory,
        "Latitude" AS latitude,
        "Longitude" AS longitude

    FROM factories

)

SELECT * FROM final
