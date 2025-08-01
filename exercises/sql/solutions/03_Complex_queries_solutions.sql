USE espn_small;

-- 1. Find the names of teams whose average player age is above the overall league average player age.
-- Approach: Subquery
SELECT
    t.name AS TeamName,
    AVG(p.age) AS AveragePlayerAge
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
GROUP BY
    t.name
HAVING
    AVG(p.age) > (SELECT AVG(age) FROM players)
ORDER BY
    AveragePlayerAge DESC;

-- 2. Which college has produced the most active players, but only consider colleges where the average age of their active players is above 28?
-- Approach: Common Table Expression (CTE)
WITH CollegeActivePlayerStats AS (
    SELECT
        c.college_id,
        c.name AS CollegeName,
        COUNT(p.player_id) AS NumberOfActivePlayers,
        AVG(p.age) AS AverageActivePlayerAge
    FROM
        players p
    JOIN
        colleges c ON p.college_id = c.college_id
    WHERE
        p.active = 1
    GROUP BY
        c.college_id, c.name
)
SELECT
    CollegeName,
    NumberOfActivePlayers
FROM
    CollegeActivePlayerStats
WHERE
    AverageActivePlayerAge > 28
ORDER BY
    NumberOfActivePlayers DESC
LIMIT 1;

-- 3. What is the total score difference (home_score - away_score) for all games in the 'regular-season' of 2023, but only for games where the total score (home + away) was above the average total score for that season?
-- Approach: Subquery
SELECT
    SUM(home_team_score - away_team_score) AS TotalScoreDifference
FROM
    games
WHERE
    season = 2023
    AND game_type = 'regular-season'
    AND (home_team_score + away_team_score) > (
        SELECT AVG(home_team_score + away_team_score)
        FROM games
        WHERE season = 2023 AND game_type = 'regular-season'
    );

-- 4. List all players who are older than the average age of players in their respective positions.
-- Approach: Subquery
SELECT
    p.firstName,
    p.lastName,
    p.age,
    pos.name AS PositionName,
    t.name AS TeamName
FROM
    players p
JOIN
    positions pos ON p.position_id = pos.position_id
JOIN
    teams t ON p.team_id = t.team_id
WHERE
    p.age > (SELECT AVG(p2.age)
             FROM players p2
             WHERE p2.position_id = p.position_id);

-- 5. For each team, find the player(s) with the highest weight.
-- Approach: Common Table Expression (CTE)
WITH TeamMaxWeight AS (
    SELECT
        team_id,
        MAX(weight) AS MaxWeight
    FROM
        players
    GROUP BY
        team_id
)
SELECT
    t.name AS TeamName,
    p.firstName,
    p.lastName,
    p.weight
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
JOIN
    TeamMaxWeight tmw ON p.team_id = tmw.team_id AND p.weight = tmw.MaxWeight;


-- 6. Calculate the winning percentage for each team in the 2023 'regular-season'.
-- Approach: Common Table Expressions (CTEs)
WITH TeamGameResults AS (
    SELECT
        home_team_id AS team_id,
        CASE WHEN home_team_score > away_team_score THEN 1 ELSE 0 END AS is_winner
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
    UNION ALL
    SELECT
        away_team_id AS team_id,
        CASE WHEN away_team_score > home_team_score THEN 1 ELSE 0 END AS is_winner
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
),
TeamWins AS (
    SELECT
        team_id,
        SUM(is_winner) AS Wins,
        COUNT(*) AS TotalGames
    FROM
        TeamGameResults
    GROUP BY
        team_id
)
SELECT
    t.name AS TeamName,
    (tw.Wins * 100.0 / tw.TotalGames) AS WinningPercentage
FROM
    TeamWins tw
JOIN
    teams t ON tw.team_id = t.team_id
ORDER BY
    WinningPercentage DESC;

-- 7. Identify games where both the home and away teams scored above the respective average scores (home and away team score) for their respective seasons.
-- Approach: Subqueries
SELECT
    g.name AS GameName,
    g.season,
    g.home_team_score,
    g.away_team_score
FROM
    games g
WHERE
    g.home_team_score > (SELECT AVG(g2.home_team_score)
                         FROM games g2
                         WHERE g2.season = g.season)
    AND g.away_team_score > (SELECT AVG(g3.away_team_score)
                             FROM games g3
                             WHERE g3.season = g.season);

-- 8. Find the top 5 colleges (by average player weight) that have at least 10 active players.
-- Approach: Subquery
SELECT
    c.name AS CollegeName,
    AVG(p.weight) AS AveragePlayerWeight
FROM
    players p
JOIN
    colleges c ON p.college_id = c.college_id
WHERE
    p.active = 1 -- Ensure we only consider active players for the count filter
    AND c.college_id IN ( -- Subquery to filter colleges with at least 10 active players
        SELECT college_id
        FROM players
        WHERE active = 1
        GROUP BY college_id
        HAVING COUNT(player_id) >= 10
    )
GROUP BY
    c.name
ORDER BY
    AveragePlayerWeight DESC
LIMIT 5;

-- 9. For each season, determine the team with the highest average score (considering both home and away games).
-- Approach: Common Table Expressions (CTEs)
WITH AllTeamScores AS (
    SELECT
        season,
        home_team_id AS team_id,
        home_team_score AS score
    FROM
        games
    UNION ALL
    SELECT
        season,
        away_team_id AS team_id,
        away_team_score AS score
    FROM
        games
),
TeamAverageScores AS (
    SELECT
        season,
        team_id,
        AVG(score) AS AvgScore
    FROM
        AllTeamScores
    GROUP BY
        season, team_id
)
SELECT
    tas.season,
    t.name AS TeamName,
    tas.AvgScore
FROM
    TeamAverageScores tas
JOIN
    teams t ON tas.team_id = t.team_id
WHERE
    (tas.season, tas.AvgScore) IN (
        SELECT season, MAX(AvgScore)
        FROM TeamAverageScores
        GROUP BY season
    )
ORDER BY
    tas.season;

-- 10. List all players who have played for a team that won more than 70% of its 'regular-season' games in 2023.
-- Approach: Common Table Expressions (CTEs)
WITH TeamGameResults AS (
    SELECT
        home_team_id AS team_id,
        CASE WHEN home_team_score > away_team_score THEN 1 ELSE 0 END AS is_winner
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
    UNION ALL
    SELECT
        away_team_id AS team_id,
        CASE WHEN away_team_score > home_team_score THEN 1 ELSE 0 END AS is_winner
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
),
TeamWinningPercentage AS (
    SELECT
        team_id,
        (SUM(is_winner) * 100.0 / COUNT(*)) AS WinningPercentage
    FROM
        TeamGameResults
    GROUP BY
        team_id
    HAVING
        WinningPercentage > 70
)
SELECT
    p.firstName,
    p.lastName,
    t.name AS TeamName,
    twp.WinningPercentage
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
JOIN
    TeamWinningPercentage twp ON t.team_id = twp.team_id;

-- 11. For each position, find the college that has produced the active player with the highest experience in that position.
-- Approach: Common Table Expression (CTE)
WITH PositionMaxExperience AS (
    SELECT
        position_id,
        MAX(experience) AS MaxExperience
    FROM
        players
    WHERE
        active = 1
    GROUP BY
        position_id
)
SELECT
    pos.name AS PositionName,
    c.name AS CollegeName,
    p.firstName,
    p.lastName,
    p.experience
FROM
    players p
JOIN
    positions pos ON p.position_id = pos.position_id
JOIN
    colleges c ON p.college_id = c.college_id
JOIN
    PositionMaxExperience pme ON p.position_id = pme.position_id AND p.experience = pme.MaxExperience
WHERE
    p.active = 1
ORDER BY
    pos.name;

-- 12. For each season that had 'post-season' games, list all distinct teams that participated.
-- Approach: Common Table Expression (CTE)
WITH PostSeasonParticipants AS (
    SELECT DISTINCT
        G.season,
        T.name AS TeamName
    FROM
        games G
    JOIN
        teams T ON G.home_team_id = T.team_id OR G.away_team_id = T.team_id
    WHERE
        G.game_type = 'post-season'
)
SELECT
    season,
    TeamName
FROM
    PostSeasonParticipants
ORDER BY
    season, TeamName;

-- 13. For each team, find the difference between their highest and lowest score in any game (home or away).
-- Approach: Common Table Expression (CTE) and Subqueries
WITH TeamScores AS (
    SELECT
        team_id,
        score
    FROM (
        SELECT
            home_team_id AS team_id,
            home_team_score AS score
        FROM
            games
        UNION ALL
        SELECT
            away_team_id AS team_id,
            away_team_score AS score
        FROM
            games
    ) AS AllScores
)
SELECT
    t.name AS TeamName,
    MAX(ts.score) - MIN(ts.score) AS ScoreDifference
FROM
    TeamScores ts
JOIN
    teams t ON ts.team_id = t.team_id
GROUP BY
    t.name
ORDER BY
    ScoreDifference DESC;

-- 14. Identify players who have the same jersey number as another player on a different team, and both players are from the same country.
-- Approach: Common Table Expression (CTE) and Self-Join
WITH PlayerJerseyCountry AS (
    SELECT
        player_id,
        firstName,
        lastName,
        team_id,
        jersey,
        country
    FROM
        players
)
SELECT
    P1.firstName,
    P1.lastName,
    T1.name AS Team1,
    P1.jersey,
    P1.country,
    P2.firstName AS OtherPlayerFirstName,
    P2.lastName AS OtherPlayerLastName,
    T2.name AS OtherPlayerTeam
FROM
    PlayerJerseyCountry P1
JOIN
    PlayerJerseyCountry P2 ON P1.jersey = P2.jersey
                AND P1.player_id <> P2.player_id
                AND P1.team_id <> P2.team_id
                AND P1.country = P2.country
JOIN
    teams T1 ON P1.team_id = T1.team_id
JOIN
    teams T2 ON P2.team_id = T2.team_id
ORDER BY
    P1.jersey, P1.country;

-- 15. Find the top 5 teams with the highest percentage of its active players whose college mascot contains the word 'Tiger'.
-- Approach: Common Table Expressions (CTEs)
WITH TeamActivePlayers AS (
    SELECT
        team_id,
        COUNT(player_id) AS TotalActivePlayers
    FROM
        players
    WHERE
        active = 1
    GROUP BY
        team_id
),
TeamTigerMascotPlayers AS (
    SELECT
        T.team_id,
        COUNT(P.player_id) AS TigerMascotPlayers
    FROM
        teams T
    JOIN
        players P ON T.team_id = P.team_id
    JOIN
        colleges C ON P.college_id = C.college_id
    WHERE
        P.active = 1 AND C.mascot LIKE '%Tiger%'
    GROUP BY
        T.team_id
)
SELECT
    T.name AS TeamName,
    (COALESCE(TMP.TigerMascotPlayers, 0) * 100.0 / TAP.TotalActivePlayers) AS PercentageTigerMascotPlayers
FROM
    teams T
JOIN
    TeamActivePlayers TAP ON T.team_id = TAP.team_id
LEFT JOIN
    TeamTigerMascotPlayers TMP ON T.team_id = TMP.team_id
ORDER BY
    PercentageTigerMascotPlayers DESC
LIMIT 5;

-- 16. For each season, calculate the cumulative sum of home team scores, ordered by game ID, and identify games where the home team score was higher than the previous game's home team score in the same season.
-- Approach: Common Table Expression (CTE) and Correlated Subqueries
WITH GameDetails AS (
    SELECT
        game_id,
        name AS GameName,
        season,
        home_team_score
    FROM
        games
)
SELECT
    gd1.game_id,
    gd1.GameName,
    gd1.season,
    gd1.home_team_score,
    (SELECT gd2.home_team_score
     FROM GameDetails gd2
     WHERE gd2.season = gd1.season AND gd2.game_id < gd1.game_id
     ORDER BY gd2.game_id DESC
     LIMIT 1) AS PreviousHomeScore,
    (SELECT SUM(gd3.home_team_score)
     FROM GameDetails gd3
     WHERE gd3.season = gd1.season AND gd3.game_id <= gd1.game_id) AS CumulativeHomeScore,
    CASE WHEN gd1.home_team_score > (SELECT gd2.home_team_score
                                     FROM GameDetails gd2
                                     WHERE gd2.season = gd1.season AND gd2.game_id < gd1.game_id
                                     ORDER BY gd2.game_id DESC
                                     LIMIT 1) THEN 'Higher than Previous' ELSE 'Not Higher' END AS ScoreComparison
FROM
    GameDetails gd1
ORDER BY
    gd1.season, gd1.game_id;

-- 17. Find all players whose weight is within 10 lbs of the average weight of players from their same college.
-- Approach: Common Table Expression (CTE)
WITH CollegeAverageWeight AS (
    SELECT
        college_id,
        AVG(weight) AS AvgCollegeWeight
    FROM
        players
    GROUP BY
        college_id
)
SELECT
    p.firstName,
    p.lastName,
    p.weight,
    c.name AS CollegeName,
    caw.AvgCollegeWeight
FROM
    players p
JOIN
    colleges c ON p.college_id = c.college_id
JOIN
    CollegeAverageWeight caw ON p.college_id = caw.college_id
WHERE
    p.weight BETWEEN caw.AvgCollegeWeight - 10 AND caw.AvgCollegeWeight + 10;

-- 18. Determine the top 3 teams with the highest average player age, and for each of those teams, list the names of players whose age is above the overall league average age.
-- Approach: Common Table Expressions (CTEs)
WITH TeamAvgAge AS (
    SELECT
        team_id,
        AVG(age) AS AverageAge
    FROM
        players
    GROUP BY
        team_id
    ORDER BY
        AverageAge DESC
    LIMIT 3
),
OverallLeagueAvgAge AS (
    SELECT
        AVG(age) AS LeagueAverageAge
    FROM
        players
)
SELECT
    t.name AS TeamName,
    p.firstName,
    p.lastName,
    p.age,
    taa.AverageAge AS TeamAverageAge,
    olaa.LeagueAverageAge
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
JOIN
    TeamAvgAge taa ON t.team_id = taa.team_id
CROSS JOIN
    OverallLeagueAvgAge olaa
WHERE
    p.age > olaa.LeagueAverageAge
ORDER BY
    TeamAverageAge DESC, p.age DESC;

-- 19. Create a temporary table of all games played in 2023, then use it to find the average home and away scores for 'regular-season' games in that year.
-- Approach: Temporary Table
CREATE TEMPORARY TABLE Games2023 AS
SELECT
    game_id,
    name,
    season,
    game_type,
    home_team_score,
    away_team_score
FROM
    games
WHERE
    season = 2023;

SELECT
    AVG(home_team_score) AS AverageHomeScore2023RegularSeason,
    AVG(away_team_score) AS AverageAwayScore2023RegularSeason
FROM
    Games2023
WHERE
    game_type = 'regular-season';

-- Clean up the temporary table (optional, but good practice)
DROP TEMPORARY TABLE IF EXISTS Games2023;
