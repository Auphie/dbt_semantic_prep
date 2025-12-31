WITH metric_date AS (

    SELECT * FROM {{ ref('dim_dates') }}

),

sales AS (

    SELECT * FROM {{ ref('fct_sales') }}

),

products AS (

    SELECT * FROM {{ ref('dim_products') }}

),

daily_factory_sales AS (

    SELECT DISTINCT
        sales.order_date::date AS sales_order_date,
        products.factory,
        ROUND(AVG(transit_days), 0) AS daily_avg_transit_days,
        SUM(sales.order_amount) AS daily_sales_amount,
        SUM(sales.gross_profit) AS daily_gross_profit,
        COUNT(DISTINCT sales.order_id) AS daily_orders,
        COUNT(DISTINCT sales.customer_id) AS daily_unique_customers

    FROM sales
    JOIN products
        ON sales.product_key = products.product_key

    GROUP BY sales.order_date::date, products.factory
),

calculate_daily_metrics AS (

    SELECT
        metric_date.date_key,
        COALESCE(this_year.factory, {{ var('null_string_value') }}) AS factory,
        COALESCE(this_year.daily_avg_transit_days, 0) AS daily_avg_transit_days,
        COALESCE(this_year.daily_sales_amount, 0) AS daily_sales_amount,
        COALESCE(this_year.daily_gross_profit, 0) AS daily_gross_profit,
        COALESCE(this_year.daily_orders, 0) AS daily_orders,
        COALESCE(this_year.daily_unique_customers, 0) AS daily_unique_customers,
        COALESCE(last_year.daily_avg_transit_days, 0) AS last_year_daily_avg_transit_days,
        COALESCE(last_year.daily_sales_amount, 0) AS last_year_daily_sales_amount,
        COALESCE(last_year.daily_gross_profit, 0) AS last_year_daily_gross_profit,
        COALESCE(last_year.daily_orders, 0) AS last_year_daily_orders,
        COALESCE(last_year.daily_unique_customers, 0) AS last_year_daily_unique_customers,
        ROUND(COALESCE(
            NULLIF(this_year.daily_avg_transit_days, 0)::numeric / NULLIF(last_year.daily_avg_transit_days, 0) * 100
            , 0, 0)) AS transit_days_index,
        ROUND(COALESCE(
            NULLIF(this_year.daily_sales_amount, 0)::numeric / NULLIF(last_year.daily_sales_amount, 0) * 100
            , 0, 0)) AS sales_amount_index,
        ROUND(COALESCE(
            NULLIF(this_year.daily_gross_profit, 0)::numeric / NULLIF(last_year.daily_gross_profit, 0) * 100
            , 0, 0)) AS gross_profit_index,
        ROUND(COALESCE(
            NULLIF(this_year.daily_orders, 0)::numeric / NULLIF(last_year.daily_orders, 0) * 100
            , 0, 0)) AS orders_index,
        ROUND(COALESCE(
            NULLIF(this_year.daily_unique_customers, 0)::numeric / NULLIF(last_year.daily_unique_customers, 0) * 100
            , 0, 2)) AS unique_customers_index

    FROM metric_date
    LEFT JOIN daily_factory_sales AS this_year
        ON metric_date.date_key = this_year.sales_order_date
    LEFT JOIN daily_factory_sales AS last_year
        ON metric_date.date_key = last_year.sales_order_date - interval '1 year'
        AND this_year.factory = last_year.factory


    WHERE this_year.sales_order_date BETWEEN '2023-01-01' AND '2023-12-31'

),

final AS (

    SELECT
        date_key,
        factory,
        daily_avg_transit_days,
        daily_sales_amount,
        daily_gross_profit,
        daily_orders,
        daily_unique_customers,
        transit_days_index,
        sales_amount_index,
        gross_profit_index,
        orders_index,
        unique_customers_index

    FROM calculate_daily_metrics

)

SELECT * FROM calculate_daily_metrics
