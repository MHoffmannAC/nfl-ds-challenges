USE espn_small;

-- 1. Pivoting Player Count by Experience Level and Position:
-- Show the count of players for each position broken down into three experience categories (0-2 yrs, 3-5 yrs, 6+ yrs).
SELECT 
    p.name AS Position,
    SUM(CASE
        WHEN pl.experience BETWEEN 0 AND 2 THEN 1
        ELSE 0
    END) AS Experience_0_2_Yrs,
    SUM(CASE
        WHEN pl.experience BETWEEN 3 AND 5 THEN 1
        ELSE 0
    END) AS Experience_3_5_Yrs,
    SUM(CASE
        WHEN pl.experience >= 6 THEN 1
        ELSE 0
    END) AS Experience_6_Plus_Yrs
FROM
    players pl
        JOIN
    positions p ON pl.position_id = p.position_id
GROUP BY p.name
ORDER BY Position;

-- 2. Pivoting Game Results (Win/Loss/Tie) by Team for 2023 Season:
-- For the 2023 season, count how many times each team recorded a Win, Loss, or Tie.
SELECT 
    t.name AS TeamName,
    SUM(CASE
        WHEN
            g.home_team_id = t.team_id
                AND g.home_team_score > g.away_team_score
        THEN
            1
        WHEN
            g.away_team_id = t.team_id
                AND g.away_team_score > g.home_team_score
        THEN
            1
        ELSE 0
    END) AS Wins,
    SUM(CASE
        WHEN
            g.home_team_id = t.team_id
                AND g.home_team_score < g.away_team_score
        THEN
            1
        WHEN
            g.away_team_id = t.team_id
                AND g.away_team_score < g.home_team_score
        THEN
            1
        ELSE 0
    END) AS Losses,
    SUM(CASE
        WHEN g.home_team_score = g.away_team_score THEN 1
        ELSE 0
    END) AS Ties
FROM
    teams t
        JOIN
    games g ON t.team_id = g.home_team_id
        OR t.team_id = g.away_team_id
WHERE
    g.season = 2023
GROUP BY t.name
ORDER BY Wins DESC;

-- 3. Pivoting Average Player Weight by Position and College Type:
-- Compare the average weight of players from 'Big' colleges (e.g., 'Alabama', 'Ohio State', 'LSU') vs. 'Other' colleges for each position.
-- Big Colleges used for this query: 'Alabama' (1), 'Ohio State' (23), 'LSU' (13).
SELECT 
    p.name AS Position,
    ROUND(AVG(CASE
                WHEN c.college_id IN (1 , 23, 13) THEN pl.weight
                ELSE NULL
            END),
            1) AS AvgWeight_BigColleges,
    ROUND(AVG(CASE
                WHEN c.college_id NOT IN (1 , 23, 13) THEN pl.weight
                ELSE NULL
            END),
            1) AS AvgWeight_OtherColleges
FROM
    players pl
        JOIN
    positions p ON pl.position_id = p.position_id
        JOIN
    colleges c ON pl.college_id = c.college_id
GROUP BY p.name
ORDER BY Position;

-- 4. Pivoting Player Count by Weight Class and Team Location Type:
-- Count players grouped by their team's location (Major Market City vs. Other) across three weight classes (< 220 lbs, 220-280 lbs, > 280 lbs).
-- Assume 'New York' and 'Los Angeles' as Major Market Cities.
SELECT
    CASE
        WHEN t.location IN ('New York', 'Los Angeles') THEN 'Major_Market_City'
        ELSE 'Other_City'
    END AS LocationType,
    SUM(CASE WHEN pl.weight < 220 THEN 1 ELSE 0 END) AS Light_Weight_Count,
    SUM(CASE WHEN pl.weight BETWEEN 220 AND 280 THEN 1 ELSE 0 END) AS Medium_Weight_Count,
    SUM(CASE WHEN pl.weight > 280 THEN 1 ELSE 0 END) AS Heavy_Weight_Count
FROM
    players pl
        JOIN
    teams t ON pl.team_id = t.team_id
GROUP BY LocationType
ORDER BY LocationType;

-- 5. Pivoting Player Height Averages by Position and College Name Group:
-- Calculate the average height of players for each position, separating them into those who attended colleges starting with A-M and N-Z.
SELECT 
    p.name AS Position,
    AVG(CASE
        WHEN c.name IS NOT NULL AND c.name BETWEEN 'A' AND 'N' THEN pl.height
        ELSE NULL
    END) AS AvgHeight_College_A_M,
    AVG(CASE
        WHEN c.name IS NOT NULL AND c.name > 'N' THEN pl.height
        ELSE NULL
    END) AS AvgHeight_College_N_Z
FROM
    players pl
        JOIN
    positions p ON pl.position_id = p.position_id
        LEFT JOIN
    colleges c ON pl.college_id = c.college_id
GROUP BY p.name
ORDER BY Position;

-- 6. Turn all previous queries into views (To create a view, use "CREATE VIEW <name for your view> AS <enter your query here>")
CREATE VIEW PlayerExperiencePivot AS
SELECT
	p.name AS Position,
	SUM(CASE WHEN pl.experience BETWEEN 0 AND 2 THEN 1 ELSE 0 END) AS Experience_0_2_Yrs,
	SUM(CASE WHEN pl.experience BETWEEN 3 AND 5 THEN 1 ELSE 0 END) AS Experience_3_5_Yrs,
	SUM(CASE WHEN pl.experience >= 6 THEN 1 ELSE 0 END) AS Experience_6_Plus_Yrs
FROM
	players pl
JOIN
	positions p ON pl.position_id = p.position_id
GROUP BY
	p.name;

CREATE VIEW GameResultsPivot AS
SELECT
	t.team_id,
	t.name AS TeamName,
	SUM(CASE
		WHEN g.home_team_id = t.team_id AND g.home_team_score > g.away_team_score THEN 1
		WHEN g.away_team_id = t.team_id AND g.away_team_score > g.home_team_score THEN 1
		ELSE 0
		END) AS Wins,
	SUM(CASE
		WHEN g.home_team_id = t.team_id AND g.home_team_score < g.away_team_score THEN 1
		WHEN g.away_team_id = t.team_id AND g.away_team_score < g.home_team_score THEN 1
		ELSE 0
		END) AS Losses,
	SUM(CASE
		WHEN g.home_team_score = g.away_team_score THEN 1
		ELSE 0
		END) AS Ties
FROM
	teams t
JOIN
	games g ON t.team_id = g.home_team_id OR t.team_id = g.away_team_id
WHERE
	g.season = 2023
GROUP BY
	t.team_id, t.name;

CREATE VIEW PlayerWeightPivot AS
SELECT
	p.name AS Position,
	ROUND(AVG(CASE WHEN c.college_id IN (1, 23, 13) THEN pl.weight ELSE NULL END), 1) AS AvgWeight_BigColleges,
	ROUND(AVG(CASE WHEN c.college_id NOT IN (1, 23, 13) THEN pl.weight ELSE NULL END), 1) AS AvgWeight_OtherColleges
FROM
	players pl
JOIN
	positions p ON pl.position_id = p.position_id
JOIN
	colleges c ON pl.college_id = c.college_id
GROUP BY
	p.name;

CREATE VIEW LocationWeightsPivot AS
SELECT
    CASE
        WHEN t.location IN ('New York', 'Los Angeles') THEN 'Major_Market_City'
        ELSE 'Other_City'
    END AS LocationType,
    SUM(CASE WHEN pl.weight < 220 THEN 1 ELSE 0 END) AS Light_Weight_Count,
    SUM(CASE WHEN pl.weight BETWEEN 220 AND 280 THEN 1 ELSE 0 END) AS Medium_Weight_Count,
    SUM(CASE WHEN pl.weight > 280 THEN 1 ELSE 0 END) AS Heavy_Weight_Count
FROM
    players pl
        JOIN
    teams t ON pl.team_id = t.team_id
GROUP BY LocationType
ORDER BY LocationType;

CREATE VIEW PositionNamePivot AS
SELECT 
    p.name AS Position,
    AVG(CASE
        WHEN c.name IS NOT NULL AND c.name BETWEEN 'A' AND 'N' THEN pl.height
        ELSE NULL
    END) AS AvgHeight_College_A_M,
    AVG(CASE
        WHEN c.name IS NOT NULL AND c.name > 'N' THEN pl.height
        ELSE NULL
    END) AS AvgHeight_College_N_Z
FROM
    players pl
        JOIN
    positions p ON pl.position_id = p.position_id
        LEFT JOIN
    colleges c ON pl.college_id = c.college_id
GROUP BY p.name
ORDER BY Position;

-- 7. Unpivot Player Counts (from Task 1):
-- Transform the pivoted player count table from Task 1 back into a normalized structure with columns:
-- Position, ExperienceCategory, and PlayerCount.
SELECT 
    Position,
    '0-2 Yrs' AS ExperienceCategory,
    Experience_0_2_Yrs AS PlayerCount
FROM
    PlayerExperiencePivot 
UNION ALL SELECT 
    Position,
    '3-5 Yrs' AS ExperienceCategory,
    Experience_3_5_Yrs AS PlayerCount
FROM
    PlayerExperiencePivot 
UNION ALL SELECT 
    Position,
    '6+ Yrs' AS ExperienceCategory,
    Experience_6_Plus_Yrs AS PlayerCount
FROM
    PlayerExperiencePivot
ORDER BY Position , ExperienceCategory;

-- 8. Unpivot Result Counts (from Task 2):
-- Transform the game result counts (Wins, Losses, Ties) into a single column, ResultType.
SELECT 
    TeamName, 'Wins' AS ResultType, Wins AS TotalCount
FROM
    GameResultsPivot 
UNION ALL SELECT 
    TeamName, 'Losses' AS ResultType, Losses AS TotalCount
FROM
    GameResultsPivot 
UNION ALL SELECT 
    TeamName, 'Ties' AS ResultType, Ties AS TotalCount
FROM
    GameResultsPivot
ORDER BY TeamName , ResultType DESC;

-- 9. Unpivot Player Weight Averages (from Task 3):
-- Unpivot the weight averages to compare the 'AvgWeight_BigColleges' and 'AvgWeight_OtherColleges' in a single column.

SELECT 
    Position,
    'Big Colleges' AS CollegeType,
    AvgWeight_BigColleges AS AverageWeight
FROM
    PlayerWeightPivot 
UNION ALL SELECT 
    Position,
    'Other Colleges' AS CollegeType,
    AvgWeight_OtherColleges AS AverageWeight
FROM
    PlayerWeightPivot
ORDER BY Position , CollegeType DESC;

-- 10. Unpivot Player Count by Weight Class and Team Location Type (from Task 4):
-- Unpivot the player counts to compare the three weight classes in a single column.
SELECT
    LocationType,
    'Light (< 220 lbs)' AS WeightClass,
    Light_Weight_Count AS PlayerCount
FROM
    LocationWeightsPivot
UNION ALL SELECT
    LocationType,
    'Medium (220-280 lbs)' AS WeightClass,
    Medium_Weight_Count AS PlayerCount
FROM
    LocationWeightsPivot
UNION ALL SELECT
    LocationType,
    'Heavy (> 280 lbs)' AS WeightClass,
    Heavy_Weight_Count AS PlayerCount
FROM
    LocationWeightsPivot
ORDER BY LocationType, PlayerCount DESC;

-- 11. Unpivot Player Height Averages (from Task 5):
-- Unpivot the height averages to compare the 'College A-M' and 'College N-Z' groups in a single column.
SELECT 
    Position,
    'College A-M' AS CollegeGroup,
    AvgHeight_College_A_M AS AverageHeight
FROM
    PositionNamePivot 
UNION ALL SELECT 
    Position,
    'College N-Z' AS CollegeGroup,
    AvgHeight_College_N_Z AS AverageHeight
FROM
    PositionNamePivot
ORDER BY Position , CollegeGroup;