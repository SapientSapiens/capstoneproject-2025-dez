{{  
  config(  
    materialized = 'table',  
    unique_key   = ['location_id', 'dateandtime', 'sensor_id']  
  )  
}}

WITH step1 as (
  select
    dateandtime,
    location_id,
    location_name,
    sensor_id,
    sensor_name,
    -- Correct CO values from ppb---→ppm since it is wrongly marked as ppb (instead of ppm) from API source
    case when sensor_name = 'CO' then value * 1000 else value end as value_ppb,
    unit
  from {{ ref('stg_hourly_data') }}
  where sensor_name not in ('TEMPERATURE', 'RELATIVEHUMIDITY') -- only pollutant shall be measured
),

step2 as (
  select
    dateandtime,
    location_id,
    location_name,
    sensor_id,
    sensor_name,
    -- Convert key pollutants to µg/m³ from ppb
    case
      when sensor_name = 'CO'  then value_ppb * 1.44
      when sensor_name = 'NO'  then value_ppb * 1.228
      when sensor_name = 'NO2' then value_ppb * 1.881
      when sensor_name = 'SO2' then value_ppb * 2.62
      else value_ppb
    end as value_ugm3,
    'µg/m³' as unit
  from step1
)

select
  dateandtime,
  location_id,
  location_name,
  sensor_id,
  sensor_name,
  ROUND(value_ugm3, 3) AS value_ugm3_rounded,
  unit
from step2