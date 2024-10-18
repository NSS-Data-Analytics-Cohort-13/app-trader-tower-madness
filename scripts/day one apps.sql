-- inner joining on name both tables with ratings and price for both




Select aps.name,  MAX(aps. rating) as aps_rating,MAX (psa. rating) as psa_rating, aps.price as aps_price,psa.price as psa_price 
from app_store_apps as aps
INNER join play_store_apps as psa
USING (name)
GROUP BY 1,4,5
ORDER BY 2 DESC,3 DESC
LIMIT 10


-- averaging both tables on price--ROUND(2 * AVG(rating)) / 2 AS rating_rounded... considering average rating and price with the higher price/the rating, though the price of row 11 Narcos: CARTEL WARS is lower rated its a better purchase as it cost less and still has longevity
question--ROUND(2 *AVG (aps.rating + psa.rating)/2,1) as avg_rating??

SELECT aps.name, ROUND(AVG (aps.rating + psa.rating)/2,1) as avg_rating, aps.price as aps_price, psa.price as psa_price
from app_store_apps as aps
inner join play_store_apps as psa
USING (name)
Group BY 1,3,4
order by avg_rating DESC
LIMIT 12



SELECT aps.name, ROUND(AVG( (aps.rating + psa.rating)/2),1) as avg_rating, aps.price as aps_price, psa.price as psa_price
from app_store_apps as aps
inner join play_store_apps as psa
USING (name)
Group BY 1,3,4
order by avg_rating DESC
LIMIT 12

-- I did a union all converting the text from play_store_apps to TEXT
-- SELECT name, price, max(rating)
-- FROM
-- (SELECT name, CAST(price as NUMERIC) as price, rating
-- FROM app_store_apps

-- UNION ALL 

-- SELECT name, Replace(trim(price),'$',''):: numeric, MAX(rating)
-- FROM play_store_apps) as combined_price
-- WHERE rating IS NOT NULL
-- GROUP BY play_store_apps,app_store_apps
-- order by rating DESC

SELECT name, ROUND(AVG(rating),1) as avg_rating
FROM
(
  -- First table (app_store_apps)
  SELECT name, CAST(price AS NUMERIC) AS price, rating
  FROM app_store_apps

 union 

  -- Second table (play_store_apps)
  SELECT name, CAST(REPLACE(TRIM(price), '$', '') AS NUMERIC) AS price, rating
  FROM play_store_apps
) AS combined_price
WHERE rating IS NOT NULL
GROUP BY name, price
ORDER BY avg_rating DESC;


-- using a Union ALL to get the average rating as well as the price

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



-- with genre and review count

WITH ratedapps as ()
SELECT combined.name,combined.price,aps.primary_genre, psa.install_count, SUM(CAST(aps.review_count AS integer) + psa.review_count) AS review_count_all,
ROUND(AVG(combined.rating),1) AS avg_rating, 
	CASE WHEN combined.price = 0 THEN combined.price + 10000
		 WHEN combined.price <= 1.00 THEN  combined.price * 10000
		 WHEN combined.price > 1.00 THEN combined.price * 10000
		 END as purchase_price
FROM (
    --app_store_apps
    SELECT name, rating,CAST(price AS NUMERIC) AS price, primary_genre
    FROM app_store_apps

    UNION ALL

    --  play_store_apps
    SELECT name, rating,Cast(REPLACE(TRIM(price),'$','') as NUMERIC) as price, genres
    FROM play_store_apps
) AS combined
JOIN app_store_apps aps ON combined.name=aps.name
join play_store_apps psa ON combined.name=psa.name
WHERE combined.name IN (
    SELECT name
    FROM app_store_apps
    INTERSECT
    SELECT name
    FROM play_store_apps
)
AND combined.rating IS NOT NULL
GROUP BY combined.name,combined.price,aps.primary_genre,psa.genres,psa.install_count,aps.review_count,psa.review_count
ORDER BY avg_rating DESC
--LIMIT 12

--streamlined query with the recommended column

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
limit 20;

----app_store_apps
    SELECT name, rating,CAST(price AS NUMERIC) AS price, primary_genre
    FROM app_store_apps

    UNION ALL

    --  play_store_apps
    SELECT name, rating,Cast(REPLACE(TRIM(price),'$','') as NUMERIC) as price, genres
    FROM play_store_apps


SELECT*
JOIN app_store_apps aps ON combined.name=aps.name
join play_store_apps psa ON combined.name=psa.name



-- different smaller queries
WITH combined
 (SELECT name,ROUND(AVG(rating),1) as avg_rating,CAST(price AS NUMERIC) AS price, CAST(review_count as integer) as review_count 
    FROM app_store_apps
	WHERE rating > 4.5
	GROUP BY content_rating,name,rating,price,review_count)

    UNION ALL

(SELECT name,ROUND(AVG(rating),1) as avg_rating,CAST(REPLACE(price, '$', '') AS DECIMAL) AS price, Review_count
    FROM play_store_apps
	WHERE rating > 4.5
	GROUP BY content_rating,name,rating,price,review_count)
	ORDER BY avg_rating DESC, review_count DESC
	LIMIT  15


--ratings check
select name,rating
from app_store_apps
where name ILIKE '%Geometry Dash Lite%'
--4.5
select name,rating
from play_store_apps
where name ILIKE '%Geo%'
--5.0