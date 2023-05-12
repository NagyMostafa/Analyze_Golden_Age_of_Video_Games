DROP TABLE game_sales;

CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold float,
  year INT
);

DROP TABLE reviews;

CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score float,   
    user_score float
);

DROP TABLE top_critic_years;

CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score float 
);

DROP TABLE top_critic_years_more_than_four_games;

CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score float 
);

DROP TABLE top_user_years_more_than_four_games;

CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score float 
);

\copy game_sales FROM 'game_sales.csv' DELIMITER ',' CSV HEADER;
\copy reviews FROM 'game_reviews.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years FROM 'top_critic_scores.csv' DELIMITER ',' CSV HEADER;
\copy top_critic_years_more_than_four_games FROM 'top_critic_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;
\copy top_user_years_more_than_four_games FROM 'top_user_scores_more_than_four_games.csv' DELIMITER ',' CSV HEADER;

--1
-- Select all information for the top ten best-selling games
-- Order the results from best-selling game down to tenth best-selling
SELECT top(10) *
FROM game_sales
ORDER BY games_sold desc

--2
-- Join games_sales and reviews
-- Select a count of the number of games where both critic_score and user_score are null
SELECT count(game_sales.game)
FROM game_sales left join reviews on game_sales.game  = reviews.game
where reviews.user_score is null and reviews.critic_score is null

--3
-- Select release year and average critic score for each year, rounded and aliased
-- Join the game_sales and reviews tables
-- Group by release year
-- Order the data from highest to lowest avg_critic_score and limit to 10 results
SELECT top(10) game_sales.year, avg(reviews.critic_score) as avg_critic_score
FROM game_sales left join reviews on game_sales.game  = reviews.game
group by game_sales.year
order by  avg_critic_score desc

--4
-- Paste your query from the previous task; update it to add a count of games released in each year called num_games
-- Update the query so that it only returns years that have more than four reviewed games
SELECT top(10) g.year, COUNT(g.game) AS num_games, ROUND(AVG(r.critic_score),2) AS avg_critic_score
FROM game_sales g
INNER JOIN reviews r
ON g.game = r.game
GROUP BY g.year
HAVING COUNT(g.game) > 4
ORDER BY avg_critic_score DESC

--5
-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 
-- Order the results from highest to lowest avg_critic_score
SELECT year, avg_critic_score
FROM top_critic_years 
except
SELECT year, avg_critic_score
FROM top_critic_years_more_than_four_games 
order by  avg_critic_score desc

--6
-- Select year, an average of user_score, and a count of games released in a given year, aliased and rounded
-- Include only years with more than four reviewed games; group data by year
-- Order data by avg_user_score, and limit to ten results
SELECT top(10) game_sales.year, avg(reviews.user_score) as avg_user_score, count(game_sales.game) as num_games
FROM game_sales join reviews on game_sales.game = reviews.game
group by year
order by  avg_user_score desc

--7
-- Select the year results that appear on both tables
SELECT year
FROM top_critic_years_more_than_four_games 
INTERSECT
SELECT year
from top_user_years_more_than_four_games
order by  year asc;
