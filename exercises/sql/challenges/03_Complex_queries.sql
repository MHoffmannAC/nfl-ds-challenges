USE espn_small;

-- 1. Find the names of teams whose average player age is above the overall league average player age. (Approach: Subquery)

-- 2. Which college has produced the most active players, but only consider colleges where the average age of their active players is above 28? (Approach: Common Table Expression (CTE))

-- 3. What is the total score difference (home_score - away_score) for all games in the 'regular-season' of 2023, but only for games where the total score (home + away) was above the average total score for that season? (Approach: Subquery)

-- 4. List all players who are older than the average age of players in their respective positions. (Approach: Subquery)

-- 5. For each team, find the player(s) with the highest weight. (Approach: Common Table Expression (CTE))

-- 6. Calculate the winning percentage for each team in the 2023 'regular-season'. (Approach: Common Table Expressions (CTEs))

-- 7. Identify games where both the home and away teams scored above the respective average scores (home and away team score) for their respective seasons. (Approach: Subqueries)

-- 8. Find the top 5 colleges (by average player weight) that have at least 10 active players. (Approach: Subquery)

-- 9. For each season, determine the team with the highest average score (considering both home and away games). (Approach: Common Table Expressions (CTEs))

-- 10. List all players who have played for a team that won more than 70% of its 'regular-season' games in 2023. (Approach: Common Table Expressions (CTEs))

-- 11. For each position, find the college that has produced the active player with the highest experience in that position. (Approach: Common Table Expression (CTE))

-- 12. For each season that had 'post-season' games, list all distinct teams that participated. (Approach: Common Table Expression (CTE))

-- 13. For each team, find the difference between their highest and lowest score in any game (home or away). (Approach: Common Table Expression (CTE) and Subqueries)

-- 14. Identify players who have the same jersey number as another player on a different team, and both players are from the same country. (Approach: Common Table Expression (CTE) and Self-Join)

-- 15. Find the top 5 teams with the highest percentage of its active players whose college mascot contains the word 'Tiger'. (Approach: Common Table Expressions (CTEs))

-- 16. For each season, calculate the cumulative sum of home team scores, ordered by game ID, and identify games where the home team score was higher than the previous game's home team score in the same season. (Approach: Common Table Expression (CTE) and Correlated Subqueries)

-- 17. Find all players whose weight is within 10 lbs of the average weight of players from their same college. (Approach: Common Table Expression (CTE))

-- 18. Determine the top 3 teams with the highest average player age, and for each of those teams, list the names of players whose age is above the overall league average age. (Approach: Common Table Expressions (CTEs))

-- 19. Create a temporary table of all games played in 2023, then use it to find the average home and away scores for 'regular-season' games in that year. (Approach: Temporary Table)