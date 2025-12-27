WITH products AS (

    SELECT * FROM {{ ref('stg_zipcodes') }}

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['zip']) }} AS postal_code_key,
        zip,
        lat,
        lng,
        city,
        state_id,
        state_name,
        zcta,
        parent_zcta,
        population,
        density,
        county_fips,
        county_name,
        county_weights,
        county_names_all,
        county_fips_all,
        imprecise,
        military,
        timezone

    FROM products

)

SELECT * FROM final
