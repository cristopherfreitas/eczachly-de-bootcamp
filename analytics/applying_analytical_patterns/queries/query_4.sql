WITH nba_dashboard AS (
    SELECT
        COALESCE(player_name, '(all players)') AS player_name,
        COALESCE(team_abbreviation, '(any team)') AS team_abbreviation,
        COALESCE(CAST(season AS VARCHAR), '(all seasons)') AS season,
        sum(pts) AS total_points
    FROM bootcamp.nba_game_details
    JOIN bootcamp.nba_games USING (game_id)
    GROUP BY GROUPING SETS (
        (player_name, team_abbreviation),
        (player_name, season),
        (team_abbreviation)
    )
)
SELECT
    player_name,
    team_abbreviation,
    total_points,
    season
FROM nba_dashboard
WHERE season != '(all seasons)'
  AND player_name != '(all players)'
  AND team_abbreviation = '(any team)'
ORDER BY total_points DESC