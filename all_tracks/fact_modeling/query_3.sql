-- Write the cumulative query to generate the device_activity_datelist field from the events table.
INSERT INTO cristophersfr.user_devices_cumulated
WITH yesterday AS (
    SELECT
        *
    FROM cristophersfr.user_devices_cumulated
    WHERE date = DATE('2022-12-31')
),
today AS (
    SELECT
        we.user_id,
        d.browser_type,
        CAST(date_trunc('day', we.event_time) as DATE) as event_date
    FROM bootcamp.web_events we
    JOIN bootcamp.devices d
    ON we.device_id = d.device_id
    WHERE CAST(date_trunc('day', we.event_time) as DATE) = DATE('2023-01-01')
    GROUP BY 1, 2, 3
)
SELECT
    COALESCE(y.user_id, t.user_id) AS user_id,
    COALESCE(y.browser_type,  t.browser_type) AS browser_type,
    CASE WHEN y.dates_active IS NOT NULL
        THEN ARRAY[t.event_date] || y.dates_active
    ELSE ARRAY[t.event_date]
    END AS dates_active,
    DATE('2023-01-01') AS date
FROM yesterday y FULL OUTER JOIN today t ON y.user_id = t.user_id