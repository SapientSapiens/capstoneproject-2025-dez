{{ config(
    materialized = 'table',
    unique_key = 'unique_record_id',
    partition_by = {
        "field": "date_day",
        "data_type": "date",
        "granularity": "day"
    },
    cluster_by = ["location_id", "sensor_id"]
) }}

WITH cte_daily_location_pollutants AS (

    SELECT
        date_for_partition AS date_day,
        sensor_id,
        sensor_name,
        location_id,
        location_name,
        AVG(pollutant_value_ugm3) AS avg_concentration
    FROM {{ ref('dim_whole_data') }}
    WHERE pollutant_value_ugm3 IS NOT NULL
    GROUP BY
        date_for_partition,
        sensor_id,
        sensor_name,
        location_id,
        location_name

)

SELECT
    {{ dbt_utils.generate_surrogate_key([
        'date_day',
        'sensor_id',
        'location_id'
    ]) }} AS unique_record_id,
    date_day,
    sensor_id,
    sensor_name,
    location_id,
    location_name,
    avg_concentration
FROM cte_daily_location_pollutants
