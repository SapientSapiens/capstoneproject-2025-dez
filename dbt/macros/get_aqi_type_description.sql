{#
    This macro returns the description of the aqi_type 
#}

{% macro get_aqi_type_description(aqi_type) -%}

    case {{ dbt.safe_cast(aqi_type, api.Column.translate_type("integer")) }}  
        when 1 then 'Good'
        when 2 then 'Satisfactory'
        when 3 then 'Moderate'
        when 4 then 'Poor'
        when 5 then 'Very Poor'
        when 6 then 'Severe'
        else 'EMPTY'
    end

{%- endmacro %}