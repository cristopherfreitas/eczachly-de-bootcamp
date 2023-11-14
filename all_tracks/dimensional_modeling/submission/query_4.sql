INSERT INTO cristophersfr.actors_history_scd
WITH lagged AS (
    SELECT
        actor,
        actor_id,
        is_active,
        LAG(is_active, 1) OVER w AS is_active_last_year,
        quality_class,
        LAG(quality_class, 1) OVER w AS quality_class_last_year,
        current_year
    FROM cristophersfr.actors
    WINDOW w AS (PARTITION BY actor_id ORDER BY current_year)
),
streaked AS (
    SELECT
        actor,
        actor_id,
        is_active,
        is_active_last_year,
        quality_class,
        quality_class_last_year,
        SUM(CASE WHEN is_active <> is_active_last_year THEN 1 ELSE 0 END) OVER w AS is_active_streak_identifier,
        SUM(CASE WHEN quality_class <> quality_class_last_year THEN 1 ELSE 0 END) OVER w AS quality_class_streak_identifier,
        current_year
    FROM lagged
    WINDOW w AS (PARTITION BY actor_id ORDER BY current_year)
)
SELECT
    actor,
    actor_id,
    MAX(quality_class) AS quality_class,
    MAX(is_active) AS is_active,
    MIN(current_year) AS start_date,
    MAX(current_year) AS end_date,
    1940 AS current_year
FROM streaked
GROUP BY actor, actor_id, is_active_streak_identifier, quality_class_streak_identifier