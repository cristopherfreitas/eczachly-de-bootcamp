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
        user_id,
        device_id,
        CAST(date_trunc('day', event_time) AS DATE) AS event_date
    FROM bootcamp.web_events
    WHERE date_trunc('day', event_time) = DATE('2023-01-01')
    GROUP BY user_id, device_id, date_trunc('day', event_time)
),
cumulated_devices AS(
    SELECT
        COALESCE(y.user_id, t.user_id) AS user_id,
        CASE
            WHEN y.device_activity_datelist IS NOT NULL AND t.device_id IS NOT NULL
                THEN
                    map_zip_with(
                        y.device_activity_datelist,
                        map(array[t.device_id], array[array[t.event_date]]),
                        (device_id, y, t) -> t || y
                    )
            WHEN y.device_activity_datelist IS NULL AND t.device_id IS NOT NULL
                THEN
                    map(array[t.device_id], array[array[t.event_date]])
        END AS device_activity_datelist,
        DATE('2023-01-01') AS date
    FROM yesterday y FULL OUTER JOIN today t ON y.user_id = t.user_id
)
SELECT
    *
FROM cumulated_devices