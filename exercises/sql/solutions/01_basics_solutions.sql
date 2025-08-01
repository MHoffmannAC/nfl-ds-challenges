USE espn_small;

-- 1. How many colleges are in the database?
SELECT
    COUNT(college_id)
FROM
    colleges;


-- 2. Create an alphabetized list of college names.
SELECT
    name
FROM
    colleges
ORDER BY name;


-- 3. Show only the teams from 'New York'.
SELECT
    *
FROM
    teams
WHERE
    location = 'New York';

-- 4. Get the full name (displayed as "abbreviation-name"), team ID, and location of teams not in 'Los Angeles'.
SELECT
    CONCAT(abbreviation, ' - ', name) AS FullName,
    team_id,
    location
FROM
    teams
WHERE
    NOT location = 'Los Angeles';


-- 5. Find the game with the highest home team score.
SELECT
    *
FROM
    games
ORDER BY home_team_score DESC
LIMIT 1;


-- 6. Which games have 'Chiefs' in their name?
SELECT DISTINCT
    name
FROM
    games
WHERE
    name LIKE '%Chiefs%';


-- 7. What is the difference in days between the earliest and latest game in the 'regular-season' for the year 2023?
SELECT
    DATEDIFF(MAX(date), MIN(date))
FROM
    games
WHERE
    game_type = 'regular-season' AND season = 2023;


-- 8. Find the total home team score and average away team score for each season.
SELECT
    season,
    SUM(home_team_score) AS TotalHomeScore,
    AVG(away_team_score) AS AverageAwayScore
FROM
    games
GROUP BY
    season;


-- 9. Find the total number of games played per game type. Only include game types with more than 10 games.
SELECT
    game_type,
    COUNT(*) AS NumberOfGames
FROM
    games
GROUP BY
    game_type
HAVING
    NumberOfGames > 10;


-- 10. Find the total number of games played per team (both home and away games). Add an extra column categorising the teams into 'High', 'Medium', 'Low' based on the number of games played. High is more than 35, Medium is between 20 and 35 (inclusive), and Low is less than 20.
SELECT
    t.name AS TeamName,
    COUNT(g.game_id) AS TotalGamesPlayed,
    CASE
        WHEN COUNT(g.game_id) > 35 THEN 'High'
        WHEN COUNT(g.game_id) BETWEEN 20 AND 35 THEN 'Medium'
        ELSE 'Low'
    END AS GameCategory
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id OR t.team_id = g.away_team_id
GROUP BY
    t.name
ORDER BY
    TotalGamesPlayed DESC;


-- 11. Find the names of teams that have played a game where their home team score was greater than 40.
SELECT DISTINCT
    t.name
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id
WHERE
    g.home_team_score > 40;


-- 12. Find all games played in the 'post-season' for the year 2023.
SELECT
    *
FROM
    games
WHERE
    game_type = 'post-season' AND season = 2023;


-- 13. List all teams whose names contain 'Bay'.
SELECT
    name
FROM
    teams
WHERE
    name LIKE '%Bay%';


-- 14. Show all colleges whose names contain 'State'.
SELECT
    *
FROM
    colleges
WHERE
    name LIKE '%State%';


-- 15. Calculate the total home team score for each location where a team is located.
SELECT
    t.location,
    SUM(g.home_team_score) AS TotalHomeScore
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id
GROUP BY
    t.location;


-- 16. Find the total number of games played by each team, broken down by home and away games.
SELECT
    t.name AS TeamName,
    SUM(CASE WHEN g.home_team_id = t.team_id THEN 1 ELSE 0 END) AS HomeGames,
    SUM(CASE WHEN g.away_team_id = t.team_id THEN 1 ELSE 0 END) AS AwayGames,
    COUNT(g.game_id) AS TotalGames
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id OR t.team_id = g.away_team_id
GROUP BY
    t.name
ORDER BY
    TotalGames DESC;


-- 17. List all games, showing the game name, and the names of both the home and away teams.
SELECT
    g.name AS GameName,
    ht.name AS HomeTeamName,
    at.name AS AwayTeamName
FROM
    games g
JOIN
    teams ht ON g.home_team_id = ht.team_id
JOIN
    teams at ON g.away_team_id = at.team_id;


-- 18. Find the minimum away team score recorded across all games.
SELECT
    MIN(away_team_score) AS MinimumAwayScore
FROM
    games;


-- 19. Find the earliest game date across all seasons.
SELECT
    MIN(date) AS EarliestGameDate
FROM
    games;


-- 20. Find seasons where the average home team score was less than 22.
SELECT
    season,
    AVG(home_team_score) AS AverageHomeScore
FROM
    games
GROUP BY
    season
HAVING
    AverageHomeScore < 22;


-- 21. Categorize games based on the home team's score: 'Low Score' (<= 10), 'Medium Score' (11-30), 'High Score' (> 30).
SELECT
    name AS GameName,
    home_team_score,
    CASE
        WHEN home_team_score <= 10 THEN 'Low Score'
        WHEN home_team_score BETWEEN 11 AND 30 THEN 'Medium Score'
        ELSE 'High Score'
    END AS ScoreCategory
FROM
    games;


-- 22. Find the top 3 teams with the highest average home team score (only considering games where they were the home team).
SELECT
    t.name AS TeamName,
    AVG(g.home_team_score) AS AverageHomeScore
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id
GROUP BY
    t.name
ORDER BY
    AverageHomeScore DESC
LIMIT 3;

-- 23. Find the names of colleges that have at least one player with more than 10 years of experience.
SELECT DISTINCT
    c.name AS CollegeName
FROM
    colleges c
JOIN
    players p ON c.college_id = p.college_id
WHERE
    p.experience > 10
ORDER BY
    CollegeName;

-- 24. Find the total number of players for each position ID.
SELECT
    position_id,
    COUNT(player_id) AS NumberOfPlayers
FROM
    players
GROUP BY
    position_id
ORDER BY
    NumberOfPlayers DESC;

-- 25. List all players who have 'Smith' in their first or last name.
SELECT
    *
FROM
    players
WHERE
    lastName LIKE '%Smith%'
    OR
    firstName LIKE '%Smith%';

-- 26. Find the average experience of players for each team.
SELECT
    t.name AS TeamName,
    AVG(p.experience) AS AveragePlayerExperience
FROM
    teams t
JOIN
    players p ON t.team_id = p.team_id
GROUP BY
    t.name
ORDER BY
    AveragePlayerExperience DESC;
