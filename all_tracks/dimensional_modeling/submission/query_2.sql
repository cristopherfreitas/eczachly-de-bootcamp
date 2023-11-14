INSERT INTO cristophersfr.actors
-- v1, window functions before
WITH last_year AS (
    SELECT *
    FROM cristophersfr.actors
    WHERE current_year = 1934
),
this_year AS (
    SELECT
        *,
        ARRAY_AGG(ROW(film, film_id, votes, rating)) OVER (PARTITION BY actor_id) AS films,
        -- The quality class is the average rating of the actor's films.
        CASE
            WHEN AVG(rating) OVER (PARTITION BY actor_id) > 8 THEN 'star'
            WHEN AVG(rating) OVER (PARTITION BY actor_id) > 7 THEN 'good'
            WHEN AVG(rating) OVER (PARTITION BY actor_id) > 6 THEN 'average'
            ELSE 'bad'
        END AS quality_class
    FROM bootcamp.actor_films
    WHERE year = 1935
),
cumulative_table AS (
    SELECT
        COALESCE(ly.actor, ty.actor) AS actor,
        COALESCE(ly.actor_id, ty.actor_id) AS actor_id,
        CASE
            -- If the actor has no new films, use the history.
            WHEN ty.films IS NULL THEN ly.films
            -- If the actor has no history, create an array with only the new one.
            WHEN ly.films IS NULL AND ty.films IS NOT NULL THEN ty.films
            -- If the actor has both history and new films, append the new ones.
            WHEN ty.films IS NOT NULL AND ly.films IS NOT NULL THEN
                ty.films || ly.films
        END AS films,
        COALESCE(ty.quality_class, ly.quality_class) AS quality_class,
        ty.year is not null as is_active,
        COALESCE(ty.year, ly.current_year + 1) as current_year
    FROM last_year ly
    FULL OUTER JOIN this_year ty
    ON ly.actor_id = ty.actor_id
)
SELECT * FROM cumulative_table
GROUP BY actor, actor_id, films, quality_class, is_active, current_year
