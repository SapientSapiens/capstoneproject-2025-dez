-- tests/generic/assert_non_negative_values.sql
{% test assert_non_negative_values(model, column_name) %}
SELECT 
    {{ column_name }} as negative_value,
    '{{ model.name }}' as model_name,
    current_timestamp() as test_timestamp
FROM {{ model }}
WHERE {{ column_name }} < 0  -- Finds all negative values
{% endtest %}