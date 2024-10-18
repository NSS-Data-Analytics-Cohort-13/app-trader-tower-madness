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
--Philip crazy formula

SELECT combined.name,
	combined.price,
	aps.primary_genre,
	psa.install_count,
	SUM(CAST(aps.review_count AS integer) + psa.review_count) AS review_count_all,
ROUND(AVG(combined.rating),1) AS avg_rating,
	CASE
		 WHEN combined.price = 0 THEN combined.price + 10000
		 WHEN combined.price <= 1.00 THEN  combined.price * 10000
		 WHEN combined.price > 1.00 THEN combined.price * 10000
		 END as purchase_price,
		 9000 as monthly_revenue,
	CASE
		 WHEN ROUND(AVG(combined.rating),1) >= 4.7 and combined.price = 0.00
		 THEN 'advisable purchase'
		 ELSE 'not recommended'
		 END as Purchase_recommendation
FROM (
    --app_store_apps
    SELECT name,
		   rating,
		   CAST(price AS NUMERIC) AS price,
		   primary_genre
    FROM app_store_apps
    UNION ALL
    --  play_store_apps
    SELECT name,
		   rating,
		   Cast(REPLACE(TRIM(price),'$','') as NUMERIC) as price,
		   genres
    FROM play_store_apps
) AS combined
JOIN app_store_apps aps ON combined.name=aps.name
join play_store_apps psa ON combined.name=psa.name
WHERE combined.rating IS NOT NULL
GROUP BY combined.name,
         combined.price,
		 aps.primary_genre,
		 psa.genres,
		 psa.install_count,
		 aps.review_count,
		 psa.review_count
ORDER BY avg_rating DESC,
		 install_count DESC,
		 purchase_price,
		 monthly_revenue DESC
-------------------------------------------------------------------------
--1) gathering names from both tables in alphabetical order
SELECT
		a.name
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING(name)
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
-----------------------------------------------------------------------------
SELECT a.name, p.name, a.rating, p.rating
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING(name)
WHERE name ilike '%instagram%'
GROUP BY a.name, p.name, a.rating, p.rating
------------------------------------------------------------------------------
--4)ADD genre (combine diff column names of primary_genre and genre)

SELECT 
		a.name
	,	a.primary_genre
	--,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	--,	ROUND(AVG((a.rating + p.rating)/2),0) AS avg_rating
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.primary_genre
--ORDER by avg_rating DESC--, avg_count DESC
-------------------------------------------------------------------------------
--5Find total number of genre categories
SELECT
		a.primary_genre
	,	COUNT(a.primary_genre) AS total_genre	
FROM app_store_apps AS a
GROUP BY a.primary_genre
ORDER BY total_genre DESC

-------------------------------------------------------------------------------
--6Find percentage
SELECT
		a.primary_genre
	,	COUNT(a.primary_genre) AS total_genre
	,	(SELECT(COUNT(a.primary_genre)) / (SELECT(COUNT(*))*100)) AS percent_total
FROM app_store_apps AS a
GROUP BY a.primary_genre
ORDER BY total_genre DESC
-------------------------------------------------------------------------------
--7find top profitability using case (recommended/not recommended)


		


--------------------------------------------------------------------------------
SELECT COUNT(*),  a.name,p.name
FROM app_store_apps AS a
INNER JOIN play_store_apps AS p
USING(name)
GROUP BY a.name, p.name
ORDER by a.name, p.name

------------------------------------------------------------------------------------
(SELECT name,ROUND(AVG(rating),1) as avg_rating,CAST(price AS NUMERIC) AS price, CAST(review_count as integer) as review_count
    FROM app_store_apps AS a
	WHERE rating > 4.5
	GROUP BY content_rating,name,rating,price,review_count)
    UNION ALL
(SELECT name,ROUND(AVG(rating),1) avg_rating,CAST(REPLACE(price, '$', '') AS DECIMAL) AS price, Review_count
    FROM play_store_apps AS p
	WHERE rating > 4.5)
	GROUP BY content_rating,name,rating,price,review_count)
	ORDER BY avg_rating DESC, review_count DESC
	LIMIT  15


