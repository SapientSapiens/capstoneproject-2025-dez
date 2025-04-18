-- tests/generic/assert_sensor_id_min_length.sql
{% test assert_sensor_id_min_length(model, column_name, min_length=8) %}
SELECT
    {{ column_name }} as invalid_value,
    LENGTH({{ column_name }}) as actual_length,
    {{ min_length }} as required_length,
    '{{ model.name }}' as model_name,
    CURRENT_TIMESTAMP() as test_timestamp
FROM {{ model }}
WHERE LENGTH({{ column_name }}) < {{ min_length }}
{% endtest %}