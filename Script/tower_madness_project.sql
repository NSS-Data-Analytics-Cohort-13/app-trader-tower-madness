SELECT *
FROM app_store_apps

SELECT *
FROM play_store_apps

(CTL+backslash to green whole query)

Select aps.name,  MAX(aps. rating) as aps_rating,MAX (psa. rating) as psa_rating, aps.price as aps_price,psa.price as psa_price
from app_store_apps as aps
INNER join play_store_apps as psa
USING (name)
GROUP BY 1,4,5
ORDER BY 2 DESC,3 DESC
LIMIT 10

-- SELECT name, ROUND(AVG(avg_rating),2) AS overall_avg_rating
-- FROM (SELECT name, AVG(rating) AS avg_rating
-- 	FROM app_store_apps
-- 	WHERE rating IS NOT NULL
-- 	GROUP BY name
-- 	INTERSECT
-- 	SELECT name, AVG(rating) AS avg_rating
-- 	FROM play_store_apps
-- 	WHERE rating IS NOT NULL
-- 	GROUP BY name) AS combined
-- GROUP BY name
-- ORDER BY overall_avg_rating DESC
-- LIMIT 10
--------------------------------------------------------------------------
--1) this query is joining both tables with rating and price for both

SELECT aps.name, ROUND(2 * AVG (aps.rating + psa.rating)/2,1) as avg_rating, aps.price as aps_price, psa.price as psa_price
from app_store_apps as aps
inner join play_store_apps as psa
USING (name)
Group BY 1,3,4
order by avg_rating DESC
LIMIT 12
--------------------------------------------------------------------------
SELECT name, CAST(price as TEXT) as price
FROM app_store_apps
UNION ALL
SELECT  name, CAST(price as TEXT) as price
FROM play_store_apps
order by price DESC

--------------------------------------------------------------------------
(select primary_genre,count(primary_genre) as tcount
from app_store_apps
group by primary_genre
order by tcount desc
limit 10)
union
(select genres,count(genres) as tcount
from play_store_apps
group by genres
order by tcount desc
limit 10)
--------------------------------------------------------------------------
(select primary_genre,count(primary_genre) as tcount,CAST(price as TEXT) as price,content_rating
from app_store_apps
group by primary_genre,price,content_rating
order by tcount desc
)
union
(select genres,count(genres) as tcount,CAST(price as TEXT) as price,content_rating
from play_store_apps
group by genres,price,content_rating
order by tcount desc
)
order by tcount desc
------------------------------------------------------------------------
SELECT name,price,
       ROUND(AVG(rating), 1) AS avg_rating
FROM (
    --app_store_apps
    SELECT name, rating,CAST(price AS NUMERIC) AS price
    FROM app_store_apps
    UNION ALL
    --  play_store_apps
    SELECT name, rating,Cast(REPLACE(TRIM(price),'$','') as NUMERIC) as price
    FROM play_store_apps
) AS combined_price
WHERE name IN (
    SELECT name
    FROM app_store_apps
    INTERSECT
    SELECT name
    FROM play_store_apps
)
AND rating IS NOT NULL
GROUP BY name,price
ORDER BY avg_rating DESC
LIMIT 12
-------------------------------------------------------------------------
--1) gathering names from both tables in alphabetical order
SELECT a.name
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
	ON a.name=p.name
	ORDER by name ASC
-------------------------------------------------------------------------
--2) Highest review count using previous quesry

SELECT 
		a.name
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
		GROUP BY a.name
ORDER by avg_count DESC
--------------------------------------------------------------------------
--3) add combined rating over 4 with total reviews(for more accurate rating)

SELECT 
		a.name
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	,	ROUND(AVG((a.rating + p.rating)/2),0) AS avg_rating
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name

		GROUP BY a.name
ORDER by avg_rating DESC, avg_count DESC
------------------------------------------------------------------------------
--4)ADD genre (combine diff column names of primary_genre and genre)

SELECT 
		a.name
	,	a.primary_genre
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	,	ROUND(AVG((a.rating + p.rating)/2),0) AS avg_rating
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.primary_genre
ORDER by avg_rating DESC, avg_count DESC
--------------------------------------------------------------------------------
--5) create a table showing count of each category and percentage of overall genre

SELECT
		a.primary_genre
	,	COUNT(*) AS genre_count
	,	ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS genre_percentage
FROM 
	app_store_apps AS a
GROUP BY
	a.primary_genre
ORDER BY
	genre_count DESC
------------------------------------------------------------------------------
--6) combine the last two
SELECT 
		a.name
	,	a.primary_genre
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	,	ROUND(AVG((a.rating + p.rating)/2),0) AS avg_rating
	,	a.primary_genre
	,	COUNT(*) AS genre_count
	,	ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS genre_percentage
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.primary_genre
ORDER by avg_rating DESC, avg_count DESC, genre_count DESC
------------------------------------------------------------------------------
--7)add the price of 0 OR 1 using case 

SELECT
		ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)AS avg_price
	,	a.name
	,	a.primary_genre
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	,	ROUND(AVG((a.rating + p.rating)/2),0) AS avg_rating
	,	a.primary_genre
	,	COUNT(*) AS genre_count
	,	ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS genre_percentage
	,	(CASE WHEN ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)<1 THEN 10000
			   WHEN ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)<2 THEN 10000
			   ELSE NULL END) AS total_price
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.primary_genre
ORDER by avg_rating DESC, avg_count DESC, genre_count DESC







