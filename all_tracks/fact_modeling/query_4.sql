WITH today AS (
    SELECT
    *
    FROM cristophersfr.user_devices_cumulated
    WHERE date = DATE('2023-01-07')
),
history AS (
    SELECT
        user_id,
        browser_type,
        CAST(
            SUM(
                CASE WHEN CONTAINS(dates_active, sequence_date)
                    THEN POW(2, 30 - DATE_DIFF('day', sequence_date, date))
                    ELSE 0
                END
            ) AS BIGINT
        ) AS history_int
    FROM today
    CROSS JOIN UNNEST (SEQUENCE(DATE('2023-01-01'), DATE('2023-01-07'))) as t(sequence_date)
    GROUP BY 1, 2
)
SELECT
    user_id,
    browser_type,
    TO_BASE(history_int, 2) AS history_in_binary,
    BIT_COUNT(history_int, 32) AS days_active
FROM history