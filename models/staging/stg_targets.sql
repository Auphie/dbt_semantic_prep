WITH targets AS (

    SELECT * FROM {{ source('seed', 'Candy_Targets') }}

),

final AS (

    SELECT
        "Division" AS division,
        "Target" AS target

    FROM targets

)

SELECT * FROM final
