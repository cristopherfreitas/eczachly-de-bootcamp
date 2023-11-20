-- Write a DDL statement to create a table called user_devices_cumulated with a device_activity_datelist field.
-- This field should look like a type MAP<STRING, ARRAY[DATE]>.
CREATE TABLE cristophersfr.user_devices_cumulated (
    user_id VARCHAR,
    device_activity_datelist MAP(VARCHAR, ARRAY(DATE)),
    date DATE
) WITH (
    format = 'PARQUET',
    partitioning = ARRAY['date']
)