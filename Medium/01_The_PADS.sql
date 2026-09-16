SELECT result
FROM (
    SELECT
        CONCAT(NAME, '(', LEFT(OCCUPATION, 1), ')') AS result,
        NAME AS sort_col,
        1 AS order_col
    FROM OCCUPATIONS

    UNION ALL

    SELECT
        CONCAT(
            'There are a total of ',
            COUNT(*),
            ' ',
            LOWER(OCCUPATION),
            's.'
        ) AS result,
        COUNT(*) AS sort_col,
        2 AS order_col
    FROM OCCUPATIONS
    GROUP BY OCCUPATION
) AS combined
ORDER BY order_col, sort_col;