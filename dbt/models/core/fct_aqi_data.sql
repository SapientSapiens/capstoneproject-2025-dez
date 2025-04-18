{{ config(materialized='table') }}

WITH

  -- 1. Base: only the four pollutants, pulling in the raw original values
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

  -- 2. Find the latest timestamp in the whole set
  latest_timestamp AS (
    SELECT
      MAX(dateandtime) AS max_time
    FROM base_data
  ),

  -- 3. Keep only the last 24 hours of data
  filtered_24hr AS (
    SELECT
      bd.*
    FROM base_data AS bd
    CROSS JOIN latest_timestamp AS lt
    WHERE bd.dateandtime >= TIMESTAMP_SUB(lt.max_time, INTERVAL 24 HOUR)
  ),

  -- 4. Compute each pollutant’s 24‑hour average at each location
  avg_pollutant_values AS (
    SELECT
      location_id,
      location_name,
      sensor_name,
      AVG(pollutant_value_original) AS avg_conc
    FROM filtered_24hr
    GROUP BY 1, 2, 3
  ),

  -- 5. Turn each avg_conc into a subindex via your macro
  pollutant_subindices AS (
    SELECT
      location_id,
      location_name,
      sensor_name,
      avg_conc,
      {{ get_pollutant_subindex() }} AS subindex
    FROM avg_pollutant_values
  ),

  -- 6. Rank pollutants by their subindex per location
  worst_subindex AS (
    SELECT
      location_id,
      location_name,
      sensor_name         AS dominant_pollutant,
      subindex,
      ROW_NUMBER() OVER (
        PARTITION BY location_id, location_name
        ORDER BY subindex DESC
      ) AS rn
    FROM pollutant_subindices
  ),

  -- 7. For each location, pick the top‑ranked pollutant as the AQI driver
  aqi_per_location AS (
    SELECT
      w.location_id,
      w.location_name,
      w.dominant_pollutant,
      w.subindex         AS aqi_value
    FROM worst_subindex AS w
    WHERE w.rn = 1
  ),

  -- 8. Map numeric AQI → description via your macro
  final_output AS (
    SELECT
      location_name      AS location,
      aqi_value,
      {{ get_aqi_type_description("aqi_value") }} AS aqi_description,
      dominant_pollutant
    FROM aqi_per_location
  )

SELECT
  location, 
  aqi_description AS air_quality,
  dominant_pollutant
FROM final_output
ORDER BY location
