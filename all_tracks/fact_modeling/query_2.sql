CREATE TABLE cristophersfr.user_devices_cumulated (
    user_id INTEGER,
    browser_type VARCHAR,
    dates_active ARRAY(DATE),
    date DATE
) WITH (
    format = 'PARQUET',
    partitioning = ARRAY['date']
)