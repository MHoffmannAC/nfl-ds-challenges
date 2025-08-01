USE espn_small;

-- 1. What is the difference between the highest and lowest home team scores recorded?
SELECT
    MAX(home_team_score) - MIN(home_team_score) AS ScoreDifference
FROM
    games;


-- 2. What is the average age of players, rounded to the nearest whole number?
SELECT
    ROUND(AVG(age)) AS AveragePlayerAge
FROM
    players;


-- 3. What is the average weight of players from the 'USA', rounded to 2 decimal places?
SELECT
    ROUND(AVG(weight), 2) AS AverageWeightUSA
FROM
    players
WHERE
    country = 'USA';


-- 4. What is the total number of games played in the 'regular-season' for the year 2023?
SELECT
    COUNT(game_id) AS TotalRegularSeasonGames2023
FROM
    games
WHERE
    season = 2023 AND game_type = 'regular-season';


-- 5. What is the average home team score for games played in the 'post-season', rounded down to the nearest integer?
SELECT
    FLOOR(AVG(home_team_score)) AS AveragePostSeasonHomeScore
FROM
    games
WHERE
    game_type = 'post-season';


-- 6. What is the average away team score for games played in the 'post-season', rounded up to the nearest integer?
SELECT
    CEIL(AVG(away_team_score)) AS AveragePostSeasonAwayScore
FROM
    games
WHERE
    game_type = 'post-season';


-- 7. For each season, what is the total combined score (home_team_score + away_team_score)?
-- Order the results from the season with the highest total combined score to the lowest.
SELECT
    season,
    SUM(home_team_score + away_team_score) AS TotalCombinedScore
FROM
    games
GROUP BY
    season
ORDER BY
    TotalCombinedScore DESC;


-- 8. Which teams have an average player weight greater than 250, rounded to the nearest whole number?
-- Include the team name and their average player weight.
SELECT
    t.name AS TeamName,
    ROUND(AVG(p.weight)) AS AveragePlayerWeight
FROM
    teams t
JOIN
    players p ON t.team_id = p.team_id
GROUP BY
    t.name
HAVING
    AveragePlayerWeight > 250;


-- 9. Classify players based on their experience: 'Rookie' (0 years), 'Developing' (1-5 years), 'Veteran' (6-10 years), 'Experienced Pro' (> 10 years).
-- Include player's first name, last name, and their experience category.
SELECT
    firstName,
    lastName,
    CASE
        WHEN experience = 0 THEN 'Rookie'
        WHEN experience BETWEEN 1 AND 5 THEN 'Developing'
        WHEN experience BETWEEN 6 AND 10 THEN 'Veteran'
        ELSE 'Experienced Pro'
    END AS ExperienceCategory
FROM
    players;


-- 10. Calculate the total number of players for each country, but only include countries with more than 10 players.
-- Order the results by the number of players in descending order.
SELECT
    country,
    COUNT(player_id) AS NumberOfPlayers
FROM
    players
GROUP BY
    country
HAVING
    COUNT(player_id) > 10
ORDER BY
    NumberOfPlayers DESC;


-- 11. Find the top 5 colleges with the highest average player age.
-- Include the college name and their average player age, rounded to 1 decimal place.
SELECT
    c.name AS CollegeName,
    ROUND(AVG(p.age), 1) AS AveragePlayerAge
FROM
    colleges c
JOIN
    players p ON c.college_id = p.college_id
GROUP BY
    c.name
ORDER BY
    AveragePlayerAge DESC
LIMIT 5;


-- 12. Determine the difference in scores between the home team and away team for each game.
-- Display the game name, home team score, away team score, and the score difference (absolute value).
SELECT
    name AS GameName,
    home_team_score,
    away_team_score,
    ABS(home_team_score - away_team_score) AS ScoreDifference
FROM
    games;


-- 13. For each team, calculate the sum of their home team scores and the sum of their away team scores.
-- Include the team name, total home score, and total away score.
SELECT
    t.name AS TeamName,
    SUM(CASE WHEN g.home_team_id = t.team_id THEN g.home_team_score ELSE 0 END) AS TotalHomeScore,
    SUM(CASE WHEN g.away_team_id = t.team_id THEN g.away_team_score ELSE 0 END) AS TotalAwayScore
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id OR t.team_id = g.away_team_id
GROUP BY
    t.name
ORDER BY
    TeamName;


-- 14. Find the game with the largest score difference between the home and away team.
-- Display the game name, home team score, away team score, and the score difference.
SELECT
    name AS GameName,
    home_team_score,
    away_team_score,
    ABS(home_team_score - away_team_score) AS ScoreDifference
FROM
    games
ORDER BY
    ScoreDifference DESC
LIMIT 1;

-- 15. For each season, find the maximum home team score and the minimum away team score.
SELECT
    season,
    MAX(home_team_score) AS MaxHomeScore,
    MIN(away_team_score) AS MinAwayScore
FROM
    games
GROUP BY
    season
ORDER BY
    season;

-- 16. What is the average height of players for each position, rounded to one decimal place?
-- Order the results by average height in descending order.
SELECT
    p_pos.name AS PositionName,
    ROUND(AVG(p.height), 1) AS AverageHeight
FROM
    players p
JOIN
    positions p_pos ON p.position_id = p_pos.position_id
GROUP BY
    p_pos.name
ORDER BY
    AverageHeight DESC;

-- 17. Rank teams by their total home team score in descending order.
-- Include team name and total home team score.
SELECT
    t.name AS TeamName,
    SUM(g.home_team_score) AS TotalHomeScore
FROM
    teams t
JOIN
    games g ON t.team_id = g.home_team_id
GROUP BY
    t.name
ORDER BY
    TotalHomeScore DESC;

-- 18. For players with an experience level between 5 and 10 years (inclusive),
-- calculate their average weight and height. Round weight to 2 decimal places and height to 1 decimal place.
SELECT
    ROUND(AVG(weight), 2) AS AverageWeight,
    ROUND(AVG(height), 1) AS AverageHeight
FROM
    players
WHERE
    experience BETWEEN 5 AND 10;

-- 19. Find the total number of active players for each team.
-- Only include teams with more than 20 active players.
SELECT
    t.name AS TeamName,
    COUNT(p.player_id) AS NumberOfActivePlayers
FROM
    teams t
JOIN
    players p ON t.team_id = p.team_id
WHERE
    p.active = 1
GROUP BY
    t.name
HAVING
    COUNT(p.player_id) > 20
ORDER BY
    NumberOfActivePlayers DESC;

-- 20. What is the total score for all 'post-season' games in 2023?
SELECT
    SUM(home_team_score + away_team_score) AS TotalPostSeasonScore2023
FROM
    games
WHERE
    season = 2023 AND game_type = 'post-season';
