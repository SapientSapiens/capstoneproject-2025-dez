{{
    config(
        materialized='table',
        cluster_by = ['year', 'month']
    )
}}

with trip_durations as (
    select
        year,
        month,
        pickup_locationid,
        pickup_zone,
        dropoff_locationid,
        dropoff_zone,
        pickup_datetime,
        dropoff_datetime,
        timestamp_diff(dropoff_datetime, pickup_datetime, second) as trip_duration
    from {{ ref('dim_fhv_trips') }}  -- Directly use dim_fhv_trips as instructed
    --where 
     --   year = 2019 
      --  and month = 11  -- November 2019 filter
),

fhv_trip_percentile as (
    SELECT 
        *,
        PERCENTILE_CONT(trip_duration, 0.90) OVER (PARTITION BY year, month, pickup_locationid, dropoff_locationid) AS p90_trip_duration 
        from trip_durations
),

p90_calculation_with_rank as ( -- seems like the rank is not being useful in getting the answers so changed to fhv_trip_percentile
    select
        year,
        month,
        pickup_zone,
        dropoff_zone,
        p90_trip_duration,
        DENSE_RANK() OVER (PARTITION BY pickup_zone ORDER BY p90_trip_duration DESC) AS p90_rank
    from fhv_trip_percentile
)

select * from fhv_trip_percentile WHERE year = 2019 AND month = 11