WITH date_spine AS (
    {{ date_spine(datepart="day",
        start_date="cast('2018-01-01' as date)",
        end_date="cast(today() + interval 2 year as date)"
     ) }}
),

base AS (

    SELECT
        cast(date_day as date) AS date_key,
        date_day,
        strftime(date_day, '%a') AS day_name,
        dayname(date_day) AS full_day_name,
        extract(month from date_day)::int AS date_month,
        extract(year from date_day)::int AS date_year,
        extract(isoyear from date_day)::int AS year_iso,
        extract(day from date_day)::int AS day_of_month,
        isodow(date_day)::int AS day_of_week,
        dayofyear(date_day)::int AS day_of_year,
        weekofyear(date_day)::int AS week_of_year,

        cast(date_trunc('week', date_day) as date) AS first_day_of_week,
        cast(date_trunc('month', date_day) as date) AS first_day_of_month,
        min(date_day) OVER (PARTITION BY extract(year from date_day)) AS first_day_of_year,
        max(date_day) OVER (PARTITION BY extract(year from date_day), extract(month from date_day)) AS last_day_of_month,
        max(date_day) OVER (PARTITION BY cast(date_trunc('week', date_day) as date)) AS last_day_of_week,
        max(date_day) OVER (PARTITION BY extract(year from date_day)) AS last_day_of_year

    FROM date_spine

),

add_yoy_dates AS (

    SELECT
        thisyear.*,
        lastyear.date_key AS last_yoy_date,
        nextyear.date_key AS next_yoy_date

    FROM base AS thisyear
    LEFT JOIN base AS lastyear
        ON
            thisyear.year_iso = lastyear.year_iso + 1
            AND thisyear.week_of_year = lastyear.week_of_year
            AND thisyear.day_of_week = lastyear.day_of_week
    LEFT JOIN base AS nextyear
        ON
            thisyear.year_iso = nextyear.year_iso - 1
            AND thisyear.week_of_year = nextyear.week_of_year
            AND thisyear.day_of_week = nextyear.day_of_week

),

final AS (

    SELECT
        date_key,
        day_name,
        full_day_name,
        date_month,
        date_year,
        year_iso,
        day_of_week,
        day_of_month,
        day_of_year,
        week_of_year,
        first_day_of_week,
        first_day_of_month,
        last_day_of_month,
        first_day_of_year,
        last_day_of_year,
        last_day_of_week,
        last_yoy_date,
        next_yoy_date

    FROM add_yoy_dates

)

SELECT * FROM final
