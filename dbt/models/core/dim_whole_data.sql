{{
    config(
        materialized='table',
        unique_key='unique_record_id',
        partition_by={
            "field": "date_for_partition",
            "data_type": "date",
            "granularity": "day"
        },
        cluster_by = ["location_id", "sensor_id"]
    )
}}

WITH historical_transformed AS (
    SELECT
        dateandtime,
        location_id,
        -- Trim location name: remove everything starting from "-3"
        REGEXP_REPLACE(location_name, r'-3.*$', '') AS location_name,
        sensor_id,
        sensor_name,
        CASE 
            WHEN sensor_name = 'CO' THEN value * 1000  -- ppm→ppb
            ELSE value
        END AS pollutant_value,
        unit,
        DATE(dateandtime) AS date_for_partition
    FROM {{ ref('stg_historical_data') }}
    -- Remove or modify the WHERE clause based on your findings
    WHERE sensor_name NOT IN ('TEMPERATURE', 'RELATIVEHUMIDITY')
),

hourly_cumulative AS (
    SELECT
        dateandtime,
        location_id,
        location_name,
        sensor_id,
        sensor_name,
        pollutant_value,
        unit,
        date_for_partition
    FROM {{ ref('dim_cumulative_hourly') }}
),

combined_data AS (
    SELECT * FROM historical_transformed
    UNION ALL
    SELECT * FROM hourly_cumulative
),


final_conversion AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['location_id', 'dateandtime', 'sensor_id']) }} AS unique_record_id,
        dateandtime,
        location_id,
        location_name,
        sensor_id,
        sensor_name,
        pollutant_value as  pollutant_value_original,
        CASE 
            WHEN sensor_name = 'CO' THEN pollutant_value * 1.44  -- ppb→µg/m³
            WHEN sensor_name = 'NO' THEN pollutant_value * 1.228
            WHEN sensor_name = 'NO2' THEN pollutant_value * 1.881
            WHEN sensor_name = 'SO2' THEN pollutant_value * 2.62
            ELSE pollutant_value
        END AS pollutant_value_ugm3,
        'µg/m³' as unit,
        date_for_partition
    FROM combined_data
)

SELECT 
    unique_record_id,
    dateandtime,
    location_id,
    location_name,
    sensor_id,
    sensor_name,
    pollutant_value_original,
    ROUND(pollutant_value_ugm3, 3) as pollutant_value_ugm3,
    unit,
    date_for_partition,
    CURRENT_TIMESTAMP() AS dbt_loaded_at
FROM final_conversion