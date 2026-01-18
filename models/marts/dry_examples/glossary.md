{# 
    This md file centralizes noun description when the noun appears with exactly the same meaning in more than 2 different models.
#}

{#
    Date related docblocks.
#}

{% docs order_date %}
Date of order in UTC.
{% enddocs %}


{#
    For keys in table/model
#}

{% docs primary_key %}
Primary key
{% enddocs %}

{% docs product_key %}
Surrogate key to `dim_products`
{% enddocs %}

{% docs postal_code_key %}
Surrogate key to `dim_postal_codes`
{% enddocs %}


{#
    Other docblocks
#}

{% docs fct_sales %}
Fact table of sales transactions (denormalized)
{% enddocs %}

{% docs cogs %}
COGS = Beginning Inventory + Purchases Made - Ending Inventory
{% enddocs %}