USE espn_small;

-- 1. Pivoting Player Count by Experience Level and Position:
-- Show the count of players for each position broken down into three experience categories (0-2 yrs, 3-5 yrs, 6+ yrs).


-- 2. Pivoting Game Results (Win/Loss/Tie) by Team for 2023 Season:
-- For the 2023 season, count how many times each team recorded a Win, Loss, or Tie.


-- 3. Pivoting Average Player Weight by Position and College Type:
-- Compare the average weight of players from 'Big' colleges (e.g., 'Alabama', 'Ohio State', 'LSU') vs. 'Other' colleges for each position.
-- Big Colleges used for this query: 'Alabama' (1), 'Ohio State' (23), 'LSU' (13).


-- 4. Pivoting Player Count by Weight Class and Team Location Type:
-- Count players grouped by their team's location (Major Market City vs. Other) across three weight classes (< 220 lbs, 220-280 lbs, > 280 lbs).
-- Assume 'New York' and 'Los Angeles' as Major Market Cities.


-- 5. Pivoting Player Height Averages by Position and College Name Group:
-- Calculate the average height of players for each position, separating them into those who attended colleges starting with A-M and N-Z.


-- 6. Turn all previous queries into views (To create a view, use "CREATE VIEW <name for your view> AS <enter your query here>")


-- 7. Unpivot Player Counts (from Task 1):
-- Transform the pivoted player count table from Task 1 back into a normalized structure with columns:
-- Position, ExperienceCategory, and PlayerCount.


-- 8. Unpivot Result Counts (from Task 2):
-- Transform the game result counts (Wins, Losses, Ties) into a single column, ResultType.


-- 9. Unpivot Player Weight Averages (from Task 3):
-- Unpivot the weight averages to compare the 'AvgWeight_BigColleges' and 'AvgWeight_OtherColleges' in a single column.


-- 10. Unpivot Player Count by Weight Class and Team Location Type (from Task 4):
-- Unpivot the player counts to compare the three weight classes in a single column.


-- 11. Unpivot Player Height Averages (from Task 5):
-- Unpivot the height averages to compare the 'College A-M' and 'College N-Z' groups in a single column.

