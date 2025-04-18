{{
    config(
        materialized='view'
    )
}}

WITH hourly_data AS (
    SELECT
        -- Fix format and Typecast dateandtime to timestamp with IST timezone
        DATETIME( FORMAT_DATETIME('%Y-%m-%d %H:%M:%S', PARSE_DATETIME('%Y-%m-%d_%H-%M-%S', dateandtime))) AS dateandtime,
        location_id,
        location_name,
        sensor_id,
        -- Capitalize sensor names
        UPPER(sensor_name) AS sensor_name,
        -- Remove negative sign from values (absolute value)
        ABS(value) AS value,
        unit AS unit
    FROM {{ source('staging', 'ext_hourly_source_data') }}
)

SELECT *
FROM hourly_data
WHERE LENGTH(sensor_id) >= 8  -- Filter for records with sensor_ids having  >=8 characters