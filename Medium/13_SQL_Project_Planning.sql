WITH PREV_TASK AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        LAG(End_Date) OVER (
            ORDER BY Start_Date
        ) AS PREV_END_DATE
    FROM Projects
),
PROJECT_GROUPS AS (
    SELECT
        Task_ID,
        Start_Date,
        End_Date,
        SUM(
            CASE
                WHEN PREV_END_DATE = Start_Date THEN 0
                ELSE 1
            END
        ) OVER (
            ORDER BY Start_Date
        ) AS PROJECT_ID
    FROM PREV_TASK
),
PROJECTS AS (
    SELECT
        PROJECT_ID,
        MIN(Start_Date) AS START_DATE,
        MAX(End_Date) AS END_DATE
    FROM PROJECT_GROUPS
    GROUP BY PROJECT_ID
)
SELECT
    START_DATE,
    END_DATE
FROM PROJECTS
ORDER BY
    DATEDIFF(END_DATE, START_DATE),
    START_DATE;