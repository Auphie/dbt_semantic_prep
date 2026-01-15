SELECT
    date_key::date AS date_day
FROM {{ ref('dim_dates') }}
