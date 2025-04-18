{{
    config(
        materialized='incremental',
        incremental_strategy='merge',  
        unique_key='unique_record_id',
        merge_update_columns=['pollutant_value'],
        partition_by={
                        "field": "date_for_partition",
                        "data_type": "date",
                        "granularity": "day"          
        }
    )
}}

WITH hourly_transformed AS (
    SELECT
        dateandtime,
        location_id,
        location_name,
        sensor_id,
        sensor_name,
        CASE 
            WHEN sensor_name = 'CO' THEN value * 1000 -- Correct CO values from ppb---→ppm since it is wrongly marked as ppb (instead of ppm) from API source
            ELSE value
        END AS pollutant_value,
        unit
    FROM {{ ref('stg_hourly_data') }}
    WHERE sensor_name NOT IN ('TEMPERATURE', 'RELATIVEHUMIDITY') -- only pollutant shall be measured
    {% if is_incremental() %}
        -- More precise than MAX(dateandtime) if data arrives late. Smarter Incremental Filter
        AND dateandtime > (
            SELECT TIMESTAMP_SUB(MAX(dateandtime), INTERVAL 1 HOUR) 
            FROM {{ this }}
        )
    {% endif %}
)

SELECT
    TO_HEX(MD5(CONCAT(
        CAST(location_id AS STRING),
        CAST(dateandtime AS STRING),
        CAST(sensor_id AS STRING)
    ))) AS unique_record_id, 
    dateandtime,
    location_id,
    location_name,
    sensor_id,
    sensor_name,
    pollutant_value,
    unit,
    DATE(dateandtime) AS date_for_partition,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM hourly_transformed