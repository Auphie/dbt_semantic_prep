WITH products AS (

    SELECT * FROM {{ ref('stg_postal_codes') }}

),

final AS (

    SELECT
        {{ dbt_utils.generate_surrogate_key(['postal_code']) }} AS postal_code_key,
        postal_code,
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
