SELECT
    COALESCE(player_name, '(all players)') AS player_id,
    COALESCE(team_abbreviation, '(any team)') AS team_id,
    COALESCE(CAST(season AS VARCHAR), '(all seasons)') AS season,
    sum(pts) AS total_points,
    COUNT(CASE WHEN home_team_wins = 1 AND team_id = home_team_id THEN 1
        WHEN home_team_wins = 0 AND team_id = team_id_away THEN 1
    ELSE 0 END) AS wins
FROM bootcamp.nba_game_details
JOIN bootcamp.nba_games USING (game_id)
GROUP BY GROUPING SETS (
    (player_name, team_abbreviation),
    (player_name, season),
    (team_abbreviation)
)