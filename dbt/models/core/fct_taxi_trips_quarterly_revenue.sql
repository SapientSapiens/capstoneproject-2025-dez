WITH qr AS (
    SELECT 
        service_type,
        EXTRACT(YEAR FROM pickup_datetime) AS year,
        EXTRACT(QUARTER FROM pickup_datetime) AS quarter,
        SUM(CAST(total_amount AS FLOAT64)) AS quarterly_revenue
    FROM {{ ref('fact_trips') }}
    WHERE EXTRACT(YEAR FROM pickup_datetime) BETWEEN 2019 AND 2020
    GROUP BY 1, 2, 3
),
yoy_growth AS (
    SELECT 
        service_type,
        year,
        quarter,
        CONCAT(CAST(year AS STRING), '/Q', CAST(quarter AS STRING)) AS year_quarter,
        quarterly_revenue,
        LAG(quarterly_revenue) OVER (
            PARTITION BY service_type, quarter 
            ORDER BY year
        ) AS prev_year_revenue
    FROM qr
)
SELECT 
    service_type,
    year_quarter,
    quarterly_revenue,
    ROUND(
        SAFE_DIVIDE(
            (quarterly_revenue - prev_year_revenue), 
            prev_year_revenue
        ) * 100, 
        2
    ) AS yoy_growth_percent
FROM yoy_growth
WHERE year = 2020
ORDER BY service_type, year_quarter