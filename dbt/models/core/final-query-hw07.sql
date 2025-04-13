{{
    config(
        materialized='view',
    )
}}

-- First, compute the second-best (penultimate) p90_trip_duration for each pickup_zone
with second_best_p90 as (
  SELECT 
    pickup_zone,
    (ARRAY_AGG(DISTINCT p90_trip_duration ORDER BY p90_trip_duration DESC))[OFFSET(1)] AS second_max
  FROM {{ ref('fct_fhv_monthly_zone_traveltime_p90') }}
  WHERE pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
  GROUP BY pickup_zone
),

-- Next, join the fact table with the computed second_max values.
filtered_facts as (
  SELECT 
    fhv.*,
    sbp.second_max
  FROM {{ ref('fct_fhv_monthly_zone_traveltime_p90') }} fhv
  LEFT JOIN second_best_p90 sbp
    ON fhv.pickup_zone = sbp.pickup_zone
  WHERE fhv.year = 2019
    AND fhv.month = 11
    AND fhv.pickup_zone IN ('Newark Airport', 'SoHo', 'Yorkville East')
    -- Only keep rows where the p90_trip_duration equals the computed second_max
    AND fhv.p90_trip_duration = sbp.second_max
),

-- Now, if multiple rows exist for the same pickup_zone group, rank them by the actual trip_duration.
ranked as (
  SELECT 
    *,
    COUNT(*) OVER (PARTITION BY pickup_zone) AS cnt,
    RANK() OVER (PARTITION BY pickup_zone ORDER BY trip_duration DESC) AS trip_rank
  FROM filtered_facts
)

-- Finally, select the row with the 2nd highest trip_duration if there are multiple rows;
-- if there is only one row (cnt = 1), that row is returned.
SELECT 
  year,
  month,
  pickup_locationid,
  pickup_zone,
  dropoff_locationid,
  dropoff_zone,
  pickup_datetime,
  dropoff_datetime,
  trip_duration,
  p90_trip_duration,
  second_max,
  trip_rank,
  cnt
FROM ranked
WHERE (cnt = 1 AND trip_rank = 1)
   OR (cnt > 1 AND trip_rank = 2)
ORDER BY pickup_zone 
