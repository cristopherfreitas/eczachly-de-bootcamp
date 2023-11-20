-- Write a query to de-duplicate the game_details table from the dimensional modeling week
-- so there are no duplicate values.
WITH nba_game_details_with_row_number AS (
    SELECT
        *,
        row_number() over w as row_number
    FROM bootcamp.nba_game_details
    WINDOW w AS (PARTITION BY game_id, team_id, player_id)
) SELECT
    *
FROM nba_game_details_with_row_number
WHERE row_number = 1
