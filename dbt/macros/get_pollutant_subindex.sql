{% macro get_pollutant_subindex() %}
  CASE 
    WHEN sensor_name = 'PM25' THEN 
      CASE
        WHEN avg_conc <= 30 THEN 1
        WHEN avg_conc <= 60 THEN 2
        WHEN avg_conc <= 90 THEN 3
        WHEN avg_conc <= 120 THEN 4
        WHEN avg_conc <= 250 THEN 5
        ELSE 6
      END
    WHEN sensor_name = 'PM10' THEN 
      CASE
        WHEN avg_conc <= 50 THEN 1
        WHEN avg_conc <= 100 THEN 2
        WHEN avg_conc <= 250 THEN 3
        WHEN avg_conc <= 350 THEN 4
        WHEN avg_conc <= 430 THEN 5
        ELSE 6
      END
    WHEN sensor_name = 'SO2' THEN 
      CASE
        WHEN avg_conc <= 16 THEN 1
        WHEN avg_conc <= 31 THEN 2
        WHEN avg_conc <= 145 THEN 3
        WHEN avg_conc <= 306 THEN 4
        WHEN avg_conc <= 611 THEN 5
        ELSE 6
      END
    WHEN sensor_name = 'NO2' THEN 
      CASE
        WHEN avg_conc <= 21 THEN 1
        WHEN avg_conc <= 43 THEN 2
        WHEN avg_conc <= 96 THEN 3
        WHEN avg_conc <= 149 THEN 4
        WHEN avg_conc <= 213 THEN 5
        ELSE 6
      END
    ELSE NULL
  END
{% endmacro %}