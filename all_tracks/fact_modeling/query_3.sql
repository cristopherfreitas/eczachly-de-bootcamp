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
        MAP_AGG(
          browser_type,
          ARRAY[CAST(date_trunc('day', event_time) AS DATE)]
        ) AS device_activity_datelist
    FROM bootcamp.web_events we
    JOIN bootcamp.devices d
    ON we.device_id = d.device_id
    WHERE date_trunc('day', event_time) = DATE('2023-01-01')
    GROUP BY user_id
),
cumulated_devices AS(
    SELECT
        COALESCE(y.user_id, t.user_id) AS user_id,
        CASE
          WHEN t.device_activity_datelist IS NULL THEN y.device_activity_datelist
          WHEN y.device_activity_datelist IS NULL THEN t.device_activity_datelist
          ELSE MAP_CONCAT(y.device_activity_datelist, t.device_activity_datelist)
        END AS device_activity_datelist,
        DATE('2023-01-01') AS date
    FROM yesterday y FULL OUTER JOIN today t ON y.user_id = t.user_id
)
SELECT
    user_id,
    MAP_AGG(
        device_key,
        ARRAY_DISTINCT(FLATTEN(MAP_VALUES(device_activity_datelist)))
    ) AS device_activity_datelist,
    date
FROM cumulated_devices
CROSS JOIN UNNEST(MAP_KEYS(device_activity_datelist)) AS t(device_key)
GROUP BY user_id, date
