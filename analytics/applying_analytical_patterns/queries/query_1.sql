DROP TABLE cristophersfr.nba_players_state;
CREATE TABLE
    cristophersfr.nba_players_state
(
    player_name         VARCHAR,
    first_active_season INT,
    last_active_season  INT,
    seasons_active      ARRAY<INT>,
    season_active_state VARCHAR,
    season              INT
)
    WITH
        (FORMAT = 'PARQUET', partitioning = ARRAY ['season'])


INSERT INTO cristophersfr.nba_players_state
WITH last_season AS (
    SELECT *
    FROM cristophersfr.nba_players_state
    WHERE season = 1998
),
this_season AS (
    SELECT *
    FROM bootcamp.nba_player_seasons
    WHERE season = 1999
),
joined AS (
    SELECT
        COALESCE(ls.player_name, ts.player_name) AS player_name,
        COALESCE(ls.first_active_season, ts.season) AS first_active_season,
        COALESCE(ts.season, ls.last_active_season) AS last_active_season,
        CASE
           WHEN ls.seasons_active IS NULL THEN ARRAY [ts.season]
           WHEN ts.season IS NULL THEN ls.seasons_active
           ELSE ls.seasons_active || ARRAY [ts.season]
        END AS seasons_active,
        CASE
            WHEN ls.player_name IS NULL AND ts.player_name IS NOT NULL THEN 'New'
            WHEN ls.last_active_season = ts.season - 1 THEN 'Continued Playing'
            WHEN ls.last_active_season < ts.season - 1 THEN 'Returned from Retirement'
            WHEN ls.last_active_season = 1999 - 1 THEN 'Retired'
            WHEN ls.last_active_season < 1999 - 1 THEN 'Stayed Retired'
        END AS season_active_state,
        1999 AS season
    FROM last_season ls
    FULL OUTER JOIN this_season ts ON ls.player_name = ts.player_name
)
SELECT player_name,
       first_active_season,
       last_active_season,
       seasons_active,
       season_active_state,
       season
FROM joined