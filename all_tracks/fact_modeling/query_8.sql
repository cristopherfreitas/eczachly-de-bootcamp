-- WARNING: Bear in mind that this query DOES NOT RUN.
-- It is reproducing what we've seen for the Fact Data Modeling Day 3 Lab, but as stated on the
-- exercise. It is not possible to run this query because the tables are not available.
INSERT INTO zachwilson.hosts_activity_reduced
WITH yesterday AS (
    SELECT
        *
    FROM cristophersfr.host_activity_reduced
    WHERE month_start = DATE('2023-08-01')
),
today AS (
    SELECT
        *
    FROM cristophersfr.daily_web_metrics
    WHERE date = DATE('2023-08-02')
)
SELECT
    COALESCE(t.host, y.host) AS host,
    COALESCE(t.metric_name, y.metric_name) AS metric_name,
    COALESCE(y.metric_array, REPEAT(null, CAST(DATE_DIFF('day', DATE('2023-08-01'), t.date) AS INTEGER))))
    '2023-08-01' AS month_start
FROM today y FULL OUTER JOIN yesterday y ON t.host = y.host AND t.metric_name = y.metric_name