{{ config(materialized="view") }}

select
    -- Identifiers: Here we generate a surrogate key from the combination of dispatching_base_num, pickup_datetime, and dropoff_datetime.
    {{ dbt_utils.generate_surrogate_key(["dispatching_base_num", "pickup_datetime", "dropoff_datetime"]) }} as tripid,
    
    -- Original columns from the FHV source
    dispatching_base_num,
    cast(pickup_datetime as timestamp) as pickup_datetime,
    cast(dropOff_datetime as timestamp) as dropoff_datetime,
    Affiliated_base_number as affiliated_base_num,
    
    -- Cast location identifiers to integer for consistency
    {{ dbt.safe_cast("PUlocationID", api.Column.translate_type("integer")) }} as pickup_locationid,
    {{ dbt.safe_cast("DOlocationID", api.Column.translate_type("integer")) }} as dropoff_locationid,
    
   SR_Flag as sr_flag
from {{ source("staging", "ext_fhv_taxi") }}
where dispatching_base_num is not null