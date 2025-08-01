USE espn_small;

-- 1a. Rank players by their total experience within each position, without using window functions.
-- Approach: Correlated Subquery
SELECT
    p.firstName,
    p.lastName,
    pos.name AS PositionName,
    p.experience,
    (SELECT COUNT(*)
     FROM players p2
     WHERE p2.position_id = p.position_id AND p2.experience > p.experience) + 1 AS ExperienceRank
FROM
    players p
JOIN
    positions pos ON p.position_id = pos.position_id
ORDER BY
    PositionName, ExperienceRank;

-- 1b. Rank players by their total experience within each position, using a window function.
-- Approach: Window Function - RANK()
SELECT
    p.firstName,
    p.lastName,
    pos.name AS PositionName,
    p.experience,
    RANK() OVER (PARTITION BY p.position_id ORDER BY p.experience DESC) AS ExperienceRank
FROM
    players p
JOIN
    positions pos ON p.position_id = pos.position_id
ORDER BY
    PositionName, ExperienceRank;

-- 2a. For each team, find the player(s) with the highest weight, without using window functions.
-- Approach: Subquery and JOIN
SELECT
    t.name AS TeamName,
    p.firstName,
    p.lastName,
    p.weight
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
JOIN (
    SELECT
        team_id,
        MAX(weight) AS MaxWeight
    FROM
        players
    GROUP BY
        team_id
) AS MaxWeightsPerTeam ON p.team_id = MaxWeightsPerTeam.team_id AND p.weight = MaxWeightsPerTeam.MaxWeight
ORDER BY
    TeamName, p.firstName, p.lastName;

-- 2b. For each team, find the player(s) with the highest weight and their rank within the team by weight, using a window function.
-- Approach: Window Function - RANK() and CTE
WITH PlayerWeightRank AS (
    SELECT
        p.team_id,
        t.name AS TeamName,
        p.firstName,
        p.lastName,
        p.weight,
        RANK() OVER (PARTITION BY p.team_id ORDER BY p.weight DESC) AS WeightRank
    FROM
        players p
    JOIN
        teams t ON p.team_id = t.team_id
)
SELECT
    TeamName,
    firstName,
    lastName,
    weight,
    WeightRank
FROM
    PlayerWeightRank
WHERE
    WeightRank = 1
ORDER BY
    TeamName;

-- 3. Calculate the running total of home team scores for each season, ordered by game date.
-- Approach: Window Function - SUM() OVER()
SELECT
    season,
    date,
    home_team_score,
    SUM(home_team_score) OVER (PARTITION BY season ORDER BY date) AS RunningHomeScoreTotal
FROM
    games
ORDER BY
    season, date;

-- 4. For each college, find the average age of its active players and the difference from the overall league average age.
-- Approach: CTEs for aggregation and calculation
WITH CollegeAvgAge AS (
    SELECT
        c.college_id,
        c.name AS CollegeName,
        AVG(p.age) AS AverageCollegePlayerAge
    FROM
        players p
    JOIN
        colleges c ON p.college_id = c.college_id
    WHERE
        p.active = 1
    GROUP BY
        c.college_id, c.name
),
OverallLeagueAvgAge AS (
    SELECT
        AVG(age) AS LeagueAverageAge
    FROM
        players
    WHERE
        active = 1
)
SELECT
    caa.CollegeName,
    caa.AverageCollegePlayerAge,
    olaa.LeagueAverageAge,
    (caa.AverageCollegePlayerAge - olaa.LeagueAverageAge) AS DifferenceFromLeagueAverage
FROM
    CollegeAvgAge caa
CROSS JOIN
    OverallLeagueAvgAge olaa
ORDER BY
    DifferenceFromLeagueAverage DESC;

-- 5a. Identify the top 3 teams with the highest average combined score (home + away) in 'regular-season' games for each year, without using window functions.
-- Approach: Subqueries and LIMIT (or complex self-joins for top-N per group)
WITH TeamSeasonAvgScore AS (
    SELECT
        g.season,
        t.name AS TeamName,
        AVG(CASE
                WHEN g.home_team_id = t.team_id THEN g.home_team_score
                ELSE g.away_team_score
            END) AS AverageTeamScore
    FROM
        games g
    JOIN
        teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
    WHERE
        g.game_type = 'regular-season'
    GROUP BY
        g.season, t.name
)
SELECT
    tsas1.season,
    tsas1.TeamName,
    tsas1.AverageTeamScore
FROM
    TeamSeasonAvgScore tsas1
WHERE (
    SELECT COUNT(*)
    FROM TeamSeasonAvgScore tsas2
    WHERE tsas2.season = tsas1.season AND tsas2.AverageTeamScore >= tsas1.AverageTeamScore
) <= 3
ORDER BY
    tsas1.season, tsas1.AverageTeamScore DESC;

-- 5b. Identify the top 3 teams with the highest average combined score (home + away) in 'regular-season' games for each year, using a window function.
-- Approach: Window Function - RANK() and CTE
WITH TeamSeasonAvgScore AS (
    SELECT
        g.season,
        t.name AS TeamName,
        AVG(CASE
                WHEN g.home_team_id = t.team_id THEN g.home_team_score
                ELSE g.away_team_score
            END) AS AverageTeamScore
    FROM
        games g
    JOIN
        teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
    WHERE
        g.game_type = 'regular-season'
    GROUP BY
        g.season, t.name
),
RankedTeamSeasonAvgScore AS (
    SELECT
        season,
        TeamName,
        AverageTeamScore,
        RANK() OVER (PARTITION BY season ORDER BY AverageTeamScore DESC) AS RankWithinSeason
    FROM
        TeamSeasonAvgScore
)
SELECT
    season,
    TeamName,
    AverageTeamScore
FROM
    RankedTeamSeasonAvgScore
WHERE
    RankWithinSeason <= 3
ORDER BY
    season, RankWithinSeason;

-- 6. For each player, determine if their current age is above, below, or equal to the average age of players from their same college.
-- Approach: Subquery and CASE statement
SELECT
    p.firstName,
    p.lastName,
    c.name AS CollegeName,
    p.age,
    (SELECT AVG(p2.age) FROM players p2 WHERE p2.college_id = p.college_id AND p2.active = 1) AS CollegeAverageAge,
    CASE
        WHEN p.age > (SELECT AVG(p2.age) FROM players p2 WHERE p2.college_id = p.college_id AND p2.active = 1) THEN 'Above College Average'
        WHEN p.age < (SELECT AVG(p2.age) FROM players p2 WHERE p2.college_id = p.college_id AND p2.active = 1) THEN 'Below College Average'
        ELSE 'Equal to College Average'
    END AS AgeComparison
FROM
    players p
JOIN
    colleges c ON p.college_id = c.college_id
WHERE
    p.active = 1;

-- 7. Find the game with the highest total score (home + away) for each season, and also show the game immediately preceding it in that season.
-- Approach: Window Functions - RANK() and LAG()
WITH GameTotalScore AS (
    SELECT
        game_id,
        season,
        date,
        home_team_score + away_team_score AS TotalScore,
        RANK() OVER (PARTITION BY season ORDER BY (home_team_score + away_team_score) DESC) AS RankTotalScore,
        LAG(game_id) OVER (PARTITION BY season ORDER BY date) AS PreviousGameID,
        LAG(date) OVER (PARTITION BY season ORDER BY date) AS PreviousGameDate,
        LAG(home_team_score + away_team_score) OVER (PARTITION BY season ORDER BY date) AS PreviousGameTotalScore
    FROM
        games
)
SELECT
    gts.season,
    gts.game_id AS CurrentGameID,
    gts.date AS CurrentGameDate,
    gts.TotalScore AS CurrentTotalScore,
    t_curr_home.name AS CurrentHomeTeam,
    t_curr_away.name AS CurrentAwayTeam,
    gts.PreviousGameID,
    gts.PreviousGameDate,
    gts.PreviousGameTotalScore,
    t_prev_home.name AS PreviousHomeTeam,
    t_prev_away.name AS PreviousAwayTeam
FROM
    GameTotalScore gts
LEFT JOIN
    games prev_g ON gts.PreviousGameID = prev_g.game_id
LEFT JOIN
    teams t_curr_home ON (SELECT home_team_id FROM games WHERE game_id = gts.game_id) = t_curr_home.team_id
LEFT JOIN
    teams t_curr_away ON (SELECT away_team_id FROM games WHERE game_id = gts.game_id) = t_curr_away.team_id
LEFT JOIN
    teams t_prev_home ON prev_g.home_team_id = t_prev_home.team_id
LEFT JOIN
    teams t_prev_away ON prev_g.away_team_id = t_prev_away.team_id
WHERE
    gts.RankTotalScore = 1
ORDER BY
    gts.season;

-- 8. List players who have a higher weight than the player immediately preceding them (by player_id) on the same team.
-- Approach: Window Function - LAG()
WITH PlayerLaggedWeight AS (
    SELECT
        p.player_id,
        p.team_id,
        p.firstName,
        p.lastName,
        p.weight,
        LAG(p.weight) OVER (PARTITION BY p.team_id ORDER BY p.player_id) AS PreviousPlayerWeight
    FROM
        players p
)
SELECT
    plw.firstName,
    plw.lastName,
    t.name AS TeamName,
    plw.weight AS CurrentPlayerWeight,
    plw.PreviousPlayerWeight
FROM
    PlayerLaggedWeight plw
JOIN
    teams t ON plw.team_id = t.team_id
WHERE
    plw.weight > plw.PreviousPlayerWeight
ORDER BY
    TeamName, plw.player_id;

-- 9. For each position, calculate the percentage of active players who have more than 5 years of experience.
-- Approach: CTE and Aggregation
WITH PositionExperienceStats AS (
    SELECT
        pos.name AS PositionName,
        COUNT(p.player_id) AS TotalActivePlayers,
        SUM(CASE WHEN p.experience > 5 THEN 1 ELSE 0 END) AS PlayersWithMoreThan5YearsExperience
    FROM
        players p
    JOIN
        positions pos ON p.position_id = pos.position_id
    WHERE
        p.active = 1
    GROUP BY
        pos.name
)
SELECT
    PositionName,
    TotalActivePlayers,
    PlayersWithMoreThan5YearsExperience,
    (PlayersWithMoreThan5YearsExperience * 100.0 / TotalActivePlayers) AS PercentageWithMoreThan5YearsExperience
FROM
    PositionExperienceStats
WHERE
    TotalActivePlayers > 0
ORDER BY
    PercentageWithMoreThan5YearsExperience DESC;

-- 10. Determine the average score difference (home_score - away_score) for each week in the 2023 'regular-season', and also show the difference from the average score difference of the previous week.
-- Approach: Window Function - AVG() and LAG()
WITH WeeklyAvgScoreDifference AS (
    SELECT
        season,
        week,
        AVG(home_team_score - away_team_score) AS AverageScoreDifference
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
    GROUP BY
        season, week
)
SELECT
    season,
    week,
    AverageScoreDifference,
    LAG(AverageScoreDifference) OVER (PARTITION BY season ORDER BY week) AS PreviousWeekAverageScoreDifference,
    AverageScoreDifference - LAG(AverageScoreDifference) OVER (PARTITION BY season ORDER BY week) AS DifferenceFromPreviousWeek
FROM
    WeeklyAvgScoreDifference
ORDER BY
    season, week;

-- 11. Find the longest winning streak (consecutive games where home team won or away team won) for any team in the 2023 'regular-season'.
-- Approach: Window Functions - RANK(), ROW_NUMBER(), SUM() OVER(), CTEs, and Self-Join
WITH TeamGameResults AS (
    SELECT
        game_id,
        date,
        season,
        home_team_id AS team_id,
        home_team_score,
        away_team_score,
        CASE WHEN home_team_score > away_team_score THEN 1 ELSE 0 END AS is_win
    FROM games
    WHERE season = 2023 AND game_type = 'regular-season'
    UNION ALL
    SELECT
        game_id,
        date,
        season,
        away_team_id AS team_id,
        away_team_score,
        home_team_score,
        CASE WHEN away_team_score > home_team_score THEN 1 ELSE 0 END AS is_win
    FROM games
    WHERE season = 2023 AND game_type = 'regular-season'
),
RankedGameResults AS (
    SELECT
        team_id,
        date,
        is_win,
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY date) AS rn,
        ROW_NUMBER() OVER (PARTITION BY team_id ORDER BY date) - SUM(is_win) OVER (PARTITION BY team_id ORDER BY date) AS grp
    FROM
        TeamGameResults
),
Streaks AS (
    SELECT
        team_id,
        is_win,
        COUNT(*) AS streak_length
    FROM
        RankedGameResults
    WHERE
        is_win = 1
    GROUP BY
        team_id, grp, is_win
),
RankedStreaks AS (
    SELECT
        team_id,
        streak_length,
        RANK() OVER (ORDER BY streak_length DESC) AS StreakRank
    FROM
        Streaks
)
SELECT
    t.name AS TeamName,
    rs.streak_length AS LongestWinningStreak
FROM
    RankedStreaks rs
JOIN
    teams t ON rs.team_id = t.team_id
WHERE
    rs.StreakRank = 1
ORDER BY
    LongestWinningStreak DESC, TeamName;

-- 12. For each player, calculate their age percentile among all players from their country.
-- Approach: Window Function - PERCENT_RANK()
SELECT
    p.firstName,
    p.lastName,
    p.country,
    p.age,
    (PERCENT_RANK() OVER (PARTITION BY p.country ORDER BY p.age)) * 100 AS AgePercentile
FROM
    players p
ORDER BY
    p.country, p.age;

-- 13. Identify teams that had a significant score swing (difference between max and min score in any game they played) within a single season, defined as a swing greater than 40 points.
-- Approach: CTE and Aggregation
WITH TeamSeasonScores AS (
    SELECT
        g.season,
        t.name AS TeamName,
        CASE
            WHEN g.home_team_id = t.team_id THEN g.home_team_score
            ELSE g.away_team_score
        END AS TeamScore
    FROM
        games g
    JOIN
        teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
),
TeamSeasonScoreStats AS (
    SELECT
        season,
        TeamName,
        MAX(TeamScore) AS MaxScore,
        MIN(TeamScore) AS MinScore,
        MAX(TeamScore) - MIN(TeamScore) AS ScoreSwing
    FROM
        TeamSeasonScores
    GROUP BY
        season, TeamName
)
SELECT
    season,
    TeamName,
    ScoreSwing
FROM
    TeamSeasonScoreStats
WHERE
    ScoreSwing > 40
ORDER BY
    ScoreSwing DESC, season, TeamName;

-- 14. For each team, list the top 5 players with the most experience, and if there's a tie in experience, break the tie by weight (heavier players ranked higher).
-- Approach: Window Function - RANK() and ORDER BY multiple columns
WITH PlayerExperienceWeightRank AS (
    SELECT
        p.team_id,
        t.name AS TeamName,
        p.firstName,
        p.lastName,
        p.experience,
        p.weight,
        RANK() OVER (PARTITION BY p.team_id ORDER BY p.experience DESC, p.weight DESC) AS PlayerRank
    FROM
        players p
    JOIN
        teams t ON p.team_id = t.team_id
)
SELECT
    TeamName,
    firstName,
    lastName,
    experience,
    weight,
    PlayerRank
FROM
    PlayerExperienceWeightRank
WHERE
    PlayerRank <= 5
ORDER BY
    TeamName, PlayerRank;

-- 15. Calculate the average height of players for each position, and for each player, show how their height compares to their position's average (e.g., 'Above Average', 'Below Average', 'Average').
-- Approach: CTE, Subquery, and CASE statement
WITH PositionAvgHeight AS (
    SELECT
        position_id,
        AVG(height) AS AvgHeight
    FROM
        players
    GROUP BY
        position_id
)
SELECT
    p.firstName,
    p.lastName,
    pos.name AS PositionName,
    p.height,
    pah.AvgHeight AS PositionAverageHeight,
    CASE
        WHEN p.height > pah.AvgHeight THEN 'Above Average'
        WHEN p.height < pah.AvgHeight THEN 'Below Average'
        ELSE 'Average'
    END AS HeightComparison
FROM
    players p
JOIN
    positions pos ON p.position_id = pos.position_id
JOIN
    PositionAvgHeight pah ON p.position_id = pah.position_id
ORDER BY
    PositionName, HeightComparison DESC, p.height DESC;

-- 16. Find the season with the highest number of 'post-season' games where the home team won by more than 10 points, and for that season, list all such games.
-- Approach: Subquery, CTE, and Aggregation with RANK()
WITH HighWinningMarginGames AS (
    SELECT
        season,
        game_id,
        date,
        home_team_id,
        away_team_id,
        home_team_score,
        away_team_score
    FROM
        games
    WHERE
        game_type = 'post-season' AND (home_team_score - away_team_score) > 10
),
SeasonWinCounts AS (
    SELECT
        season,
        COUNT(game_id) AS NumberOfGames,
        RANK() OVER (ORDER BY COUNT(game_id) DESC) AS RankNumGames
    FROM
        HighWinningMarginGames
    GROUP BY
        season
)
SELECT
    hwmg.season,
    hwmg.game_id,
    hwmg.date,
    th.name AS HomeTeam,
    hwmg.home_team_score,
    ta.name AS AwayTeam,
    hwmg.away_team_score
FROM
    HighWinningMarginGames hwmg
JOIN
    SeasonWinCounts swc ON hwmg.season = swc.season
JOIN
    teams th ON hwmg.home_team_id = th.team_id
JOIN
    teams ta ON hwmg.away_team_id = ta.team_id
WHERE
    swc.RankNumGames = 1
ORDER BY
    hwmg.season, hwmg.date;

-- 17. For each team, find the average age of players whose jersey number is even, and the average age of players whose jersey number is odd.
-- Approach: Conditional Aggregation
SELECT
    t.name AS TeamName,
    AVG(CASE WHEN p.jersey % 2 = 0 THEN p.age ELSE NULL END) AS AverageAgeEvenJersey,
    AVG(CASE WHEN p.jersey % 2 <> 0 THEN p.age ELSE NULL END) AS AverageAgeOddJersey
FROM
    players p
JOIN
    teams t ON p.team_id = t.team_id
WHERE
    p.jersey IS NOT NULL
GROUP BY
    t.name
ORDER BY
    t.name;

-- 18. Determine the top 5 colleges that have produced the most players who are currently active and have an experience level greater than the average experience level of all active players.
-- Approach: CTEs for aggregation and ranking with RANK()
WITH OverallActiveAvgExperience AS (
    SELECT
        AVG(experience) AS LeagueAverageExperience
    FROM
        players
    WHERE
        active = 1
),
CollegePlayerCounts AS (
    SELECT
        c.college_id,
        c.name AS CollegeName,
        COUNT(p.player_id) AS NumberOfQualifiedPlayers
    FROM
        players p
    JOIN
        colleges c ON p.college_id = c.college_id
    CROSS JOIN
        OverallActiveAvgExperience oaae
    WHERE
        p.active = 1 AND p.experience > oaae.LeagueAverageExperience
    GROUP BY
        c.college_id, c.name
),
RankedCollegePlayerCounts AS (
    SELECT
        CollegeName,
        NumberOfQualifiedPlayers,
        RANK() OVER (ORDER BY NumberOfQualifiedPlayers DESC) AS CollegeRank
    FROM
        CollegePlayerCounts
)
SELECT
    CollegeName,
    NumberOfQualifiedPlayers
FROM
    RankedCollegePlayerCounts
WHERE
    CollegeRank <= 5
ORDER BY
    NumberOfQualifiedPlayers DESC, CollegeName;

-- 19. For each game in the 2023 'regular-season', calculate the cumulative average total score (home + away) up to that game, ordered by game date.
-- Approach: Window Function - AVG() OVER()
SELECT
    game_id,
    date,
    (home_team_score + away_team_score) AS TotalScore,
    AVG(home_team_score + away_team_score) OVER (ORDER BY date) AS CumulativeAverageTotalScore
FROM
    games
WHERE
    season = 2023 AND game_type = 'regular-season'
ORDER BY
    date;

-- 20. Identify players who have the same first name and last name as another player, but play for different teams and have different positions.
-- Approach: Self-Join and Complex WHERE clause
SELECT
    p1.firstName,
    p1.lastName,
    t1.name AS Team1Name,
    pos1.name AS Position1Name,
    t2.name AS Team2Name,
    pos2.name AS Position2Name
FROM
    players p1
JOIN
    players p2 ON p1.firstName = p2.firstName AND p1.lastName = p2.lastName
JOIN
    teams t1 ON p1.team_id = t1.team_id
JOIN
    teams t2 ON p2.team_id = t2.team_id
JOIN
    positions pos1 ON p1.position_id = pos1.position_id
JOIN
    positions pos2 ON p2.position_id = pos2.position_id
WHERE
    p1.player_id <> p2.player_id
    AND p1.team_id <> p2.team_id
    AND p1.position_id <> p2.position_id
ORDER BY
    p1.firstName, p1.lastName;

-- 21. For each team, calculate the total score they scored (sum of home_team_score when they were home and away_team_score when they were away) in the 2023 'regular-season', and rank them by this total score.
-- Approach: CTE, UNION ALL, and Window Function - RANK()
WITH TeamScores AS (
    SELECT
        home_team_id AS team_id,
        home_team_score AS score
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
    UNION ALL
    SELECT
        away_team_id AS team_id,
        away_team_score AS score
    FROM
        games
    WHERE
        season = 2023 AND game_type = 'regular-season'
),
TeamTotalScores AS (
    SELECT
        team_id,
        SUM(score) AS TotalScore
    FROM
        TeamScores
    GROUP BY
        team_id
)
SELECT
    t.name AS TeamName,
    tts.TotalScore,
    RANK() OVER (ORDER BY tts.TotalScore DESC) AS RankTotalScore
FROM
    TeamTotalScores tts
JOIN
    teams t ON tts.team_id = t.team_id
ORDER BY
    RankTotalScore;

-- 22. Find the players who have the highest "value" within their team, where "value" is defined as (experience * 0.6 + age * 0.4) and rank them by this value.
-- Approach: Window Function - RANK() and custom calculation
WITH PlayerValue AS (
    SELECT
        p.team_id,
        t.name AS TeamName,
        p.firstName,
        p.lastName,
        p.experience,
        p.age,
        (p.experience * 0.6 + p.age * 0.4) AS PlayerCalculatedValue,
        RANK() OVER (PARTITION BY p.team_id ORDER BY (p.experience * 0.6 + p.age * 0.4) DESC) AS ValueRank
    FROM
        players p
    JOIN
        teams t ON p.team_id = t.team_id
)
SELECT
    TeamName,
    firstName,
    lastName,
    experience,
    age,
    PlayerCalculatedValue,
    ValueRank
FROM
    PlayerValue
WHERE
    ValueRank = 1
ORDER BY
    TeamName, PlayerCalculatedValue DESC;

-- 23. For each season, identify the week with the highest total score across all games played in that week.
-- Approach: CTE and Aggregation with RANK()
WITH WeeklyTotalScores AS (
    SELECT
        season,
        week,
        SUM(home_team_score + away_team_score) AS TotalScorePerWeek
    FROM
        games
    GROUP BY
        season, week
),
RankedWeeklyScores AS (
    SELECT
        season,
        week,
        TotalScorePerWeek,
        RANK() OVER (PARTITION BY season ORDER BY TotalScorePerWeek DESC) AS WeekRank
    FROM
        WeeklyTotalScores
)
SELECT
    season,
    week,
    TotalScorePerWeek
FROM
    RankedWeeklyScores
WHERE
    WeekRank = 1
ORDER BY
    season, week;

-- 24. Calculate the average weight of players for each country, and then for each player, find the percentage difference between their weight and the average weight of players from their country.
-- Approach: CTE and Arithmetic
WITH CountryAvgWeight AS (
    SELECT
        country,
        AVG(weight) AS AverageCountryWeight
    FROM
        players
    WHERE
        country IS NOT NULL
    GROUP BY
        country
)
SELECT
    p.firstName,
    p.lastName,
    p.country,
    p.weight AS PlayerWeight,
    caw.AverageCountryWeight,
    ( (p.weight - caw.AverageCountryWeight) / caw.AverageCountryWeight ) * 100 AS PercentageDifferenceFromCountryAverage
FROM
    players p
JOIN
    CountryAvgWeight caw ON p.country = caw.country
ORDER BY
    p.country, PercentageDifferenceFromCountryAverage DESC;

-- 25. For each team, list players who have a higher jersey number than at least two other players on the same team, and also have a lower age than the average age of players with the same position across the entire league.
-- Approach: CTEs, Window Function - COUNT() with JOIN
WITH PositionLeagueAvgAge AS (
    SELECT
        position_id,
        AVG(age) AS LeagueAvgAge
    FROM
        players
    GROUP BY
        position_id
),
PlayerJerseyRank AS (
    SELECT
        p.player_id,
        p.team_id,
        p.firstName,
        p.lastName,
        p.jersey,
        p.age,
        p.position_id,
        COUNT(p2.player_id) AS PlayersWithLowerJersey
    FROM
        players p
    JOIN
        players p2 ON p.team_id = p2.team_id AND p.jersey > p2.jersey
    GROUP BY
        p.player_id, p.team_id, p.firstName, p.lastName, p.jersey, p.age, p.position_id
)
SELECT
    t.name AS TeamName,
    pjr.firstName,
    pjr.lastName,
    pjr.jersey,
    pjr.age,
    pos.name AS PositionName
FROM
    PlayerJerseyRank pjr
JOIN
    teams t ON pjr.team_id = t.team_id
JOIN
    positions pos ON pjr.position_id = pos.position_id
JOIN
    PositionLeagueAvgAge plaa ON pjr.position_id = plaa.position_id
WHERE
    pjr.PlayersWithLowerJersey >= 2
    AND pjr.age < plaa.LeagueAvgAge
ORDER BY
    TeamName, pjr.jersey DESC;

-- 26. Determine the three consecutive games in the 2023 'regular-season' for any team that had the highest cumulative total score.
-- Approach: Window Functions - SUM() OVER() with ROWS BETWEEN, and RANK()
WITH TeamGameScores AS (
    SELECT
        g.game_id,
        g.date,
        g.season,
        g.home_team_id AS team_id,
        g.home_team_score AS team_score,
        g.away_team_score AS opponent_score
    FROM
        games g
    WHERE g.season = 2023 AND g.game_type = 'regular-season'
    UNION ALL
    SELECT
        g.game_id,
        g.date,
        g.season,
        g.away_team_id AS team_id,
        g.away_team_score AS team_score,
        g.home_team_score AS opponent_score
    FROM
        games g
    WHERE g.season = 2023 AND g.game_type = 'regular-season'
),
CumulativeScores AS (
    SELECT
        team_id,
        date,
        team_score,
        SUM(team_score) OVER (PARTITION BY team_id ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Cumulative3GameScore
    FROM
        TeamGameScores
),
RankedCumulativeScores AS (
    SELECT
        team_id,
        date,
        Cumulative3GameScore,
        RANK() OVER (ORDER BY Cumulative3GameScore DESC) AS CumulativeRank
    FROM
        CumulativeScores
)
SELECT
    t.name AS TeamName,
    rcs.date AS EndGameDate,
    rcs.Cumulative3GameScore
FROM
    RankedCumulativeScores rcs
JOIN
    teams t ON rcs.team_id = t.team_id
WHERE
    rcs.CumulativeRank = 1
ORDER BY
    rcs.Cumulative3GameScore DESC, TeamName, EndGameDate;

-- 27. Identify teams that have had at least 3 games in a season where their score (home or away) was above the season's average total game score.
-- Approach: CTEs, Conditional Aggregation
WITH SeasonAvgTotalScore AS (
    SELECT
        season,
        AVG(home_team_score + away_team_score) AS AvgTotalScore
    FROM
        games
    GROUP BY
        season
),
TeamGameScoresAboveAverage AS (
    SELECT
        g.season,
        CASE
            WHEN g.home_team_id = t.team_id THEN g.home_team_id
            ELSE g.away_team_id
        END AS team_id,
        CASE
            WHEN g.home_team_id = t.team_id THEN g.home_team_score
            ELSE g.away_team_score
        END AS team_score,
        sat.AvgTotalScore
    FROM
        games g
    JOIN
        teams t ON g.home_team_id = t.team_id OR g.away_team_id = t.team_id
    JOIN
        SeasonAvgTotalScore sat ON g.season = sat.season
    WHERE
        (CASE WHEN g.home_team_id = t.team_id THEN g.home_team_score ELSE g.away_team_score END) > sat.AvgTotalScore
)
SELECT
    t.name AS TeamName,
    tgsaa.season,
    COUNT(tgsaa.team_id) AS GamesAboveAverage
FROM
    TeamGameScoresAboveAverage tgsaa
JOIN
    teams t ON tgsaa.team_id = t.team_id
GROUP BY
    t.name, tgsaa.season
HAVING
    COUNT(tgsaa.team_id) >= 3
ORDER BY
    tgsaa.season, GamesAboveAverage DESC;

-- 28. For each college, identify the player with the longest name (firstName + lastName) among its active players, and if there's a tie, pick the one with the highest experience.
-- Approach: CTE and Window Function - ROW_NUMBER()
WITH PlayerNameLength AS (
    SELECT
        p.college_id,
        c.name AS CollegeName,
        p.firstName,
        p.lastName,
        p.experience,
        LENGTH(CONCAT(p.firstName, p.lastName)) AS FullNameLength,
        ROW_NUMBER() OVER (PARTITION BY p.college_id ORDER BY LENGTH(CONCAT(p.firstName, p.lastName)) DESC, p.experience DESC) AS rn
    FROM
        players p
    JOIN
        colleges c ON p.college_id = c.college_id
    WHERE
        p.active = 1
)
SELECT
    CollegeName,
    firstName,
    lastName,
    experience,
    FullNameLength
FROM
    PlayerNameLength
WHERE
    rn = 1
ORDER BY
    CollegeName;

-- 29. Analyze game outcomes: For each season, calculate the percentage of games where the home team won, away team won, or it was a tie.
-- Approach: CTE and Conditional Aggregation
WITH SeasonGameOutcomes AS (
    SELECT
        season,
        COUNT(game_id) AS TotalGames,
        SUM(CASE WHEN home_team_score > away_team_score THEN 1 ELSE 0 END) AS HomeWins,
        SUM(CASE WHEN away_team_score > home_team_score THEN 1 ELSE 0 END) AS AwayWins,
        SUM(CASE WHEN home_team_score = away_team_score THEN 1 ELSE 0 END) AS Ties
    FROM
        games
    GROUP BY
        season
)
SELECT
    season,
    TotalGames,
    (HomeWins * 100.0 / TotalGames) AS PercentageHomeWins,
    (AwayWins * 100.0 / TotalGames) AS PercentageAwayWins,
    (Ties * 100.0 / TotalGames) AS PercentageTies
FROM
    SeasonGameOutcomes
ORDER BY
    season;

-- 30. For each team and season, identify the game where they had their largest winning margin (home_score - away_score if home, away_score - home_score if away), and if there's a tie, pick the game with the highest total score.
-- Approach: CTEs, Window Functions - ROW_NUMBER(), CASE
WITH TeamGameMargins AS (
    SELECT
        g.game_id,
        g.season,
        g.date,
        g.home_team_id AS team_id,
        t_home.name AS TeamName,
        g.home_team_score,
        g.away_team_score,
        (g.home_team_score - g.away_team_score) AS WinningMargin,
        (g.home_team_score + g.away_team_score) AS TotalScore
    FROM
        games g
    JOIN
        teams t_home ON g.home_team_id = t_home.team_id
    WHERE
        g.home_team_score > g.away_team_score -- Home team won
    UNION ALL
    SELECT
        g.game_id,
        g.season,
        g.date,
        g.away_team_id AS team_id,
        t_away.name AS TeamName,
        g.home_team_score,
        g.away_team_score,
        (g.away_team_score - g.home_team_score) AS WinningMargin,
        (g.home_team_score + g.away_team_score) AS TotalScore
    FROM
        games g
    JOIN
        teams t_away ON g.away_team_id = t_away.team_id
    WHERE
        g.away_team_score > g.home_team_score -- Away team won
),
RankedGameMargins AS (
    SELECT
        game_id,
        season,
        date,
        team_id,
        TeamName,
        home_team_score,
        away_team_score,
        WinningMargin,
        TotalScore,
        ROW_NUMBER() OVER (PARTITION BY team_id, season ORDER BY WinningMargin DESC, TotalScore DESC) AS rn
    FROM
        TeamGameMargins
)
SELECT
    TeamName,
    season,
    date,
    home_team_score,
    away_team_score,
    WinningMargin,
    TotalScore
FROM
    RankedGameMargins
WHERE
    rn = 1
ORDER BY
    TeamName, season;
