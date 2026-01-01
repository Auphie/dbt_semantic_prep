WITH date_spine AS (
    {{ date_spine(datepart="day",
        start_date="to_date('01/01/2018', 'MM/DD/YYYY')",
        end_date="current_date + interval '2 year'"
     ) }}
),

base AS (

    SELECT
        date_day::date AS date_key,
        date_day,
        to_char(date_day, 'Dy') AS day_name,
        to_char(date_day, 'FMDay') AS full_day_name,
        DATE_PART('month', date_day) AS date_month,
        DATE_PART('year', date_day) AS date_year,
        extract(isoyear from date_day)::int AS year_iso,
        DATE_PART('day', date_day)::int AS day_of_month,
        extract(isodow from date_day)::int AS day_of_week,
        extract(doy from date_day)::int AS day_of_year,
        extract(week from date_day)::int AS week_of_year,

        date_trunc('week', date_day)::date AS first_day_of_week,
        date_trunc('month', date_day)::date AS first_day_of_month,
        min(date_day) OVER (PARTITION BY DATE_PART('year', date_day)) AS first_day_of_year,
        max(date_day) OVER (PARTITION BY DATE_PART('year', date_day), DATE_PART('month', date_day)) AS last_day_of_month,
        max(date_day) OVER (PARTITION BY date_trunc('week', date_day)::date) AS last_day_of_week,
        max(date_day) OVER (PARTITION BY DATE_PART('year', date_day)) AS last_day_of_year

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
