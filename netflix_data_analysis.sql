CREATE DATABASE netflix;
use netflix;

CREATE TABLE netflix_data (
show_id VARCHAR(6),
type VARCHAR(10),
title VARCHAR(150),
director VARCHAR(250),
cast VARCHAR(1000),
country	VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating VARCHAR(10),
duration VARCHAR(10),
listed_in VARCHAR(100),
description VARCHAR(250)
);

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

LOAD DATA LOCAL INFILE 'C:/Users/lalit/Saved Games/Downloads/netflix_titles.csv'
INTO TABLE netflix_data
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW WARNINGS;

SELECT *
FROM netflix_data;

select count(show_id)
from netflix_data;

-- 1.Count number of movies vs tv shows
SELECT type, COUNT(*) as total_content
FROM netflix_data
group by type;

-- 2.Find the most common rating for movies and tv shows
SELECT type, rating 
from
(SELECT type,rating, count(*),
rank() over(partition by type order by count(*) desc) as ranking
from netflix_data
group by 1,2) as t1
where ranking=1;

-- 3.List all movies released in specific year
SELECT *
from netflix_data
where release_year=2020 and type='Movie';

-- 4.Top 5 countries with more content on netflix

SELECT country, COUNT(show_id) AS total_content
FROM netflix_data
WHERE country IS NOT NULL AND TRIM(country) != ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5.Identify the longest movie (max duration)

select * from netflix_data
where type='Movie'
and 
duration = (select max(duration) from netflix_data);

-- 6.Find the content added in last 5 years

select * 
from netflix_data
WHERE STR_TO_DATE(date_added, '%M %d, %Y') IS NOT NULL
  AND STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Find all movies/ tv shows by specific director
select director, count(*) as count
from netflix_data
group by 1
order by 2 desc;

select *
from netflix_data
where director LIKE 'Rajiv Chilaka';

-- 8. List all tv shows with more than 5 seasons

SELECT *,
       SUBSTRING_INDEX(duration, ' ', 1) AS d
FROM netflix_data
WHERE type = 'TV Show'
  AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5
  AND duration LIKE '%Season%';
  
-- 9.count no of content items in each genre

select count(show_id), listed_in
from netflix_data
group by listed_in;

-- 10. Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release

select YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) as year_added, count(show_id)/12.0 AS avg_count
from netflix_data
WHERE country='India'
group by 1
order by 2 DESC
LIMIT 5;

-- 11. List all movies that are documentaries

select *
from netflix_data
where listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director

select *
from netflix_data
where director is null or TRIM(director)='';

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select *
from netflix_data
where cast LIKE '%Salman Khan%' and YEAR(str_to_date(date_added, '%M %d, %Y'))>=YEAR(curdate())-10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.