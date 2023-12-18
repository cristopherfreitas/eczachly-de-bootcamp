CREATE TABLE cristophersfr.actors (
    actor         VARCHAR,
    actor_id      VARCHAR,
    films         ARRAY( ROW (
        film VARCHAR,
        film_id VARCHAR,
        votes INTEGER,
        rating DOUBLE
        )),
    quality_class VARCHAR,
    is_active     BOOLEAN,
    current_year  INTEGER
)
WITH (
    format = 'PARQUET',
    partitioning = ARRAY['current_year']
)