WITH ranked AS (
    SELECT
        LAT_N,
        ROW_NUMBER() OVER (ORDER BY LAT_N) AS rn,
        COUNT(*) OVER () AS total
    FROM STATION
)
SELECT
    ROUND(AVG(LAT_N), 4)
FROM ranked
WHERE rn IN (
    FLOOR((total + 1) / 2),
    FLOOR((total + 2) / 2)
);