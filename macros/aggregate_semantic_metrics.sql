{%- macro aggregate_semantic_metrics(
    input_name,
    dimensions,
    time_dimension,
    filters,
    unique_metrics,
    cummulative_metrics,
    ratio_metrics) -%}
    SELECT
        {%- for dimension in dimensions %}
        {{ dimension }},
        {%- endfor -%}
        {%- if unique_metrics is not none -%}
        {%- for metric in unique_metrics %}
        COUNT(DISTINCT {{ metric }}) AS {{ metric }}_count,
        {%- endfor -%}
        {% endif %}
        {%- if cummulative_metrics is not none -%}
        {% for metric in cummulative_metrics %}
        SUM({{ metric }}) AS {{ metric }},
        {%- endfor -%}
        {% endif %}
        {%- if ratio_metrics is not none -%}
        {% for metric in ratio_metrics %}
        -- Placeholder for ratio metrics
        -- aggregated_metric_A / aggregated_metric_B AS {{ metric }}
        {%- endfor -%}
        {% endif %}
        DATE_PART('{{ time_dimension }}', order_date) AS {{ time_dimension }}

    FROM {{ input_name }}
    {% if filters is not none %}
    WHERE true
    {%- for filter in filters %}
        AND {{ filter }}
    {%- endfor -%}
    {% endif %}

    GROUP BY
        {%- for dimension in dimensions %}
        {{ dimension }},
        DATE_PART('{{ time_dimension }}', order_date)
        {%- endfor -%}

{%- endmacro %}