-- Write the cumulative query to generate the device_activity_datelist field from the events table.
WITH yesterday AS (
    SELECT
        *
    FROM cristophersfr.user_devices_cumulated
    WHERE date = DATE('2022-12-31')
),
today AS (
    SELECT
        user_id,
        device_id,
        CAST(date_trunc('day', event_time) AS DATE) AS event_date,
        COUNT(1)
    FROM bootcamp.web_events
    WHERE date_trunc('day', event_time) = DATE('2023-01-01')
    GROUP BY user_id, device_id, date_trunc('day', event_time)
),
cumulated_devices AS(
    SELECT
        COALESCE(y.user_id, t.user_id) AS user_id,
        CASE
            -- `device_activity_datelist` is not empty
            WHEN y.device_activity_datelist IS NOT NULL
                THEN
                    multimap_from_entries(
                        map_entries(y.device_activity_datelist) ||
                        ARRAY_AGG(ROW(t.device_id, ARRAY[t.event_date])) OVER (PARTITION BY t.device_id)
                    )
            ELSE
                multimap_from_entries(
                    ARRAY_AGG((t.device_id, ARRAY[t.event_date])) OVER (PARTITION BY t.device_id)
                )
        END AS device_activity_datelist
    FROM yesterday y FULL OUTER JOIN today t ON y.user_id = t.user_id
)
SELECT
    *
FROM cumulated_devices