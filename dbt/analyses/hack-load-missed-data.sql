-- SINCE THE DBT MODELS WERE DEVELOPED LATER AND THE HOURLY SENSORS DATA FOR THE LOCATIONS
-- HAVE ACCUMULATED. SO WE LOAD THEM INTO THE EXTERNAL TABLE AND GET IT CONSUMED BY THE STAGING
-- TABLE. NOTE THIS IS ONLY A ONE-TIME ACTIVITY.

 CREATE OR REPLACE EXTERNAL TABLE `dez-capstone-project1.air_quality_assam_dataset.ext_hourly_source_data`
      (
          dateandtime   STRING,
          location_id   STRING,
          location_name STRING,
          sensor_id     STRING,
          sensor_name   STRING,
          value         FLOAT64,
          unit          STRING,
          dlt_load_id   STRING,
          dlt_id        STRING
      ) 
      OPTIONS (
              format = 'CSV',
              uris = ['gs://air-quality-assam-bucket/hourly_data/*.csv'],
              skip_leading_rows = 1,
              ignore_unknown_values = TRUE
      );


  -- AND DO --->> dbt build --full-refresh