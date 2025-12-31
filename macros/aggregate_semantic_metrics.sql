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
        {{ dimension }}{% if not loop.last %},{% endif %}
        {%- endfor -%}
        {%- if unique_metrics is not none -%}
        {%- for metric in unique_metrics %}
        ,COUNT(DISTINCT {{ metric }}) AS {{ metric }}_count
        {%- endfor -%}
        {% endif %}
        {%- if cummulative_metrics is not none -%}
        {% for metric in cummulative_metrics %}
        ,SUM({{ metric }}) AS {{ metric }}
        {%- endfor -%}
        {% endif %}
        {%- if ratio_metrics is not none -%}
        {% for metric in ratio_metrics %}
        -- Placeholder for ratio metrics
        -- aggregated_metric_A / aggregated_metric_B AS {{ metric }}
        {%- endfor -%}
        {% endif %}

    FROM {{ input_name }}

    WHERE {{ time_dimension }}
    {%- if filters is not none -%}
    {% for filter in filters %}
        AND {{ filter }}
    {%- endfor -%}
    {% endif %}

    GROUP BY
        {%- for dimension in dimensions %}
        {{ dimension }}{% if not loop.last %},{% endif %}
        {%- endfor -%}

{%- endmacro %}