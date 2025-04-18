{{ config(materialized='table') }}

WITH
base_data AS (
  SELECT
    location_id,
    location_name,
    sensor_name,
    pollutant_value_original,
    dateandtime
  FROM {{ ref('dim_whole_data') }}
  WHERE sensor_name IN ('PM25', 'PM10', 'SO2', 'NO2')
),

latest_timestamp AS (
  SELECT MAX(dateandtime) AS max_time FROM base_data
),

filtered_24hr AS (
  SELECT
    bd.*
  FROM base_data AS bd
  CROSS JOIN latest_timestamp AS lt
  WHERE bd.dateandtime >= TIMESTAMP_SUB(lt.max_time, INTERVAL 24 HOUR)
),

avg_pollutant_values AS (
  SELECT
    location_id,
    location_name,
    sensor_name,
    AVG(pollutant_value_original) AS avg_conc
  FROM filtered_24hr
  GROUP BY 1, 2, 3
  HAVING COUNT(*) = 16 -- Ensure 16h data completeness
),

pollutant_subindices AS (
  SELECT
    location_id,
    location_name,
    sensor_name,
    avg_conc,
    {{ get_pollutant_subindex() }} AS subindex
  FROM avg_pollutant_values
),

valid_locations AS (
  SELECT
    location_id,
    location_name,
    COUNT(DISTINCT sensor_name) AS pollutant_count,
    COUNT(DISTINCT CASE WHEN sensor_name IN ('PM25', 'PM10') THEN sensor_name END) AS pm_count
  FROM pollutant_subindices
  GROUP BY 1, 2
  HAVING pollutant_count >= 3 AND pm_count >= 1
),

worst_subindex AS (
  SELECT
    location_id,
    location_name,
    sensor_name,
    subindex,
    ROW_NUMBER() OVER (
      PARTITION BY location_id, location_name 
      ORDER BY subindex DESC
    ) AS pollutant_rank
  FROM pollutant_subindices
),

aqi_per_location AS (
  SELECT
    ws.location_id,
    ws.location_name,
    ws.sensor_name AS dominant_pollutant,
    ws.subindex AS aqi_value
  FROM worst_subindex ws
  JOIN valid_locations vl 
    ON ws.location_id = vl.location_id 
    AND ws.location_name = vl.location_name
  WHERE ws.pollutant_rank = 1
),

final_output AS (
  SELECT
    location_name AS location,
    {{ get_aqi_type_description("aqi_value") }} AS air_quality,
    dominant_pollutant,
    aqi_value
  FROM aqi_per_location
)

SELECT 
  location, 
  air_quality, 
  dominant_pollutant 
FROM final_output
ORDER BY location