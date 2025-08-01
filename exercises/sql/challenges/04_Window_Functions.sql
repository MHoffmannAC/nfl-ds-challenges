USE espn_small;

-- 1a. Rank players by their total experience within each position, without using window functions.
-- 1b. Rank players by their total experience within each position, using a window function. (Approach: Window Function - RANK())

-- 2a. For each team, find the player(s) with the highest weight, without using window functions.
-- 2b. For each team, find the player(s) with the highest weight and their rank within the team by weight, using a window function. (Approach: Window Function - RANK() and CTE)

-- 3. Calculate the running total of home team scores for each season, ordered by game date. (Approach: Window Function - SUM() OVER())

-- 4. For each college, find the average age of its active players and the difference from the overall league average age. (Approach: CTEs for aggregation and calculation)

-- 5a. Identify the top 3 teams with the highest average combined score (home + away) in 'regular-season' games for each year, without using window functions.
-- 5b. Identify the top 3 teams with the highest average combined score (home + away) in 'regular-season' games for each year, using a window function. (Approach: Window Function - RANK() and CTE)

-- 6. For each player, determine if their current age is above, below, or equal to the average age of players from their same college. (Approach: Subquery and CASE statement)

-- 7. Find the game with the highest total score (home + away) for each season, and also show the game immediately preceding it in that season. (Approach: Window Functions - RANK() and LAG())

-- 8. List players who have a higher weight than the player immediately preceding them (by player_id) on the same team. (Approach: Window Function - LAG())

-- 9. For each position, calculate the percentage of active players who have more than 5 years of experience. (Approach: CTE and Aggregation)

-- 10. Determine the average score difference (home_score - away_score) for each week in the 2023 'regular-season', and also show the difference from the average score difference of the previous week. (Approach: Window Function - AVG() and LAG())

-- 11. Find the longest winning streak (consecutive games where home team won or away team won) for any team in the 2023 'regular-season'. (Approach: Window Functions, CTEs, and Self-Join)

-- 12. For each player, calculate their age percentile among all players from their country. (Approach: Window Function - PERCENT_RANK())

-- 13. Identify teams that had a significant score swing (difference between max and min score in any game they played) within a single season, defined as a swing greater than 40 points. (Approach: CTE and Aggregation)

-- 14. For each team, list the top 5 players with the most experience, and if there's a tie in experience, break the tie by weight (heavier players ranked higher). (Approach: Window Function - RANK() and ORDER BY multiple columns)

-- 15. Calculate the average height of players for each position, and for each player, show how their height compares to their position's average (e.g., 'Above Average', 'Below Average', 'Average'). (Approach: CTE, Subquery, and CASE statement)

-- 16. Find the season with the highest number of 'post-season' games where the home team won by more than 10 points, and for that season, list all such games. (Approach: Subquery, CTE, and Aggregation with RANK())

-- 17. For each team, find the average age of players whose jersey number is even, and the average age of players whose jersey number is odd. (Approach: Conditional Aggregation)

-- 18. Determine the top 5 colleges that have produced the most players who are currently active and have an experience level greater than the average experience level of all active players. (Approach: CTEs for aggregation and ranking with RANK())

-- 19. For each game in the 2023 'regular-season', calculate the cumulative average total score (home + away) up to that game, ordered by game date. (Approach: Window Function - AVG() OVER())

-- 20. Identify players who have the same first name and last name as another player, but play for different teams and have different positions. (Approach: Self-Join and Complex WHERE clause)

-- 21. For each team, calculate the total score they scored (sum of home_team_score when they were home and away_team_score when they were away) in the 2023 'regular-season', and rank them by this total score. (Approach: CTE, UNION ALL, and Window Function - RANK())

-- 22. Find the players who have the highest "value" within their team, where "value" is defined as (experience * 0.6 + age * 0.4) and rank them by this value. (Approach: Window Function - RANK() and custom calculation)

-- 23. For each season, identify the week with the highest total score across all games played in that week. (Approach: CTE and Aggregation with RANK())

-- 24. Calculate the average weight of players for each country, and then for each player, find the percentage difference between their weight and the average weight of players from their country. (Approach: CTE and Arithmetic)

-- 25. For each team, list players who have a higher jersey number than at least two other players on the same team, and also have a lower age than the average age of players with the same position across the entire league. (Approach: CTEs, Window Function - COUNT() with JOIN)

-- 26. Determine the three consecutive games in the 2023 'regular-season' for any team that had the highest cumulative total score. (Approach: Window Functions - SUM() OVER() with ROWS BETWEEN, and RANK())

-- 27. Identify teams that have had at least 3 games in a season where their score (home or away) was above the season's average total game score. (Approach: CTEs, Conditional Aggregation)

-- 28. For each college, identify the player with the longest name (firstName + lastName) among its active players, and if there's a tie, pick the one with the highest experience. (Approach: CTE and Window Function - ROW_NUMBER())

-- 29. Analyze game outcomes: For each season, calculate the percentage of games where the home team won, away team won, or it was a tie. (Approach: CTE and Conditional Aggregation)

-- 30. For each team and season, identify the game where they had their largest winning margin (home_score - away_score if home, away_score - home_score if away), and if there's a tie, pick the game with the highest total score. (Approach: CTEs, Window Functions - ROW_NUMBER(), CASE)
