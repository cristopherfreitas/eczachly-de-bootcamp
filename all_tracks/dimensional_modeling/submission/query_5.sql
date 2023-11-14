INSERT INTO cristophersfr.actors_history_scd
WITH last_year_scd AS (
    SELECT
        *
    FROM cristophersfr.actors_history_scd
    WHERE current_year = 1940
),
current_year_scd AS (
    SELECT
        *
    FROM cristophersfr.actors
    WHERE current_year = 1941
),
combined AS (
    SELECT
        COALESCE(ly.actor_id, cy.actor_id) AS actor_id,
        COALESCE(ly.actor, cy.actor) AS actor,
        COALESCE(ly.start_date, cy.current_year) AS start_date,
        COALESCE(ly.end_date, cy.current_year) AS end_date,
        ly.is_active as is_active_last_year,
        cy.is_active as is_active_this_year,
        ly.quality_class as quality_class_last_year,
        cy.quality_class as quality_class_this_year,
        CASE
            WHEN ly.quality_class <> cy.quality_class OR ly.is_active <> cy.is_active THEN 1
            WHEN ly.quality_class = cy.quality_class OR ly.is_active = cy.is_active THEN 0
        END AS did_change,
        1941 AS current_year
    FROM last_year_scd ly
    FULL OUTER JOIN current_year_scd cy
        ON ly.actor_id = cy.actor_id
        AND ly.end_date + 1 = cy.current_year
),
changes AS (
    SELECT
        actor,
        actor_id,
        CASE
            WHEN did_change = 0
                THEN ARRAY[ROW(quality_class_last_year, is_active_last_year, start_date, end_date + 1)]
            WHEN did_change = 1
                THEN ARRAY[
                    ROW(quality_class_last_year, is_active_last_year, start_date, end_date),
                    ROW(quality_class_this_year, is_active_this_year, current_year, current_year)
                ]
            WHEN did_change IS NULL
                THEN ARRAY[ROW(
                    COALESCE(quality_class_last_year, quality_class_last_year),
                    COALESCE(is_active_last_year, is_active_this_year),
                    start_date,
                    end_date
                    )
                ]
        END AS change_array,
        current_year
    FROM combined
)
SELECT
    actor,
    actor_id,
    arr.quality_class,
    arr.is_active,
    arr.start_date,
    arr.end_date,
    current_year
FROM changes
CROSS JOIN UNNEST(change_array) AS arr(quality_class,is_active, start_date, end_date)
