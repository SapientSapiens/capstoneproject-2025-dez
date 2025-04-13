{{
    config(
        materialized='table'
    )
}}

with fhv_trips as (
    select 
        *,
        extract(year from pickup_datetime) as year,
        extract(month from pickup_datetime) as month
    from {{ ref('stg_fhv_tripdata') }}
)

select 
    fhv.*,
    pickup_zone.zone as pickup_zone,
    dropoff_zone.zone as dropoff_zone
from fhv_trips fhv
inner join {{ ref('dim_zones') }} pickup_zone
    on fhv.pickup_locationid = pickup_zone.locationid
inner join {{ ref('dim_zones') }} dropoff_zone
    on fhv.dropoff_locationid = dropoff_zone.locationid