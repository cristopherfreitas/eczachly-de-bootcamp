INSERT INTO cristophersfr.hosts_cumulated
WITH yesterday AS (
    SELECT
        *
    FROM cristophersfr.hosts_cumulated
    WHERE date = DATE('2022-12-31')
),
today AS (
    SELECT
        host,
        CAST(date_trunc('day', we.event_time) as DATE) as event_date
    FROM bootcamp.web_events we
    WHERE CAST(date_trunc('day', we.event_time) as DATE) = DATE('2023-01-01')
    GROUP BY 1, 2
)
SELECT
    COALESCE(y.host, t.host) AS user_id,
    CASE WHEN y.host_activity_datelist IS NOT NULL
        THEN ARRAY[t.event_date] || y.host_activity_datelist
    ELSE ARRAY[t.event_date]
    END AS dates_active,
    DATE('2023-01-01') AS date
FROM yesterday y FULL OUTER JOIN today t ON y.host = t.host