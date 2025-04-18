{{
    config(
        materialized='view'
    )
}}

SELECT
    -- Typecast dateandtime to timestamp with IST timezone
    DATETIME(TIMESTAMP(dateandtime), 'Asia/Kolkata') AS dateandtime,
    location_id,
    -- Trim location name: remove everything starting from "-3"
    REGEXP_REPLACE(location_name, r'-3.*$', '') AS location_name,
    sensor_id,
    -- Capitalize sensor names
    UPPER(sensor_name) AS sensor_name,
    -- Remove negative sign from values (absolute value)
    ABS(value) AS value,
    unit AS unit

FROM {{ source('staging', 'ext_historical_source_data') }}