select primary_genre from app_store_apps where primary_genre ='Catalogs'

select * from play_store_apps
select * from app_store_apps

--average
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

--------------------------------------------------
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
--end query


select a.name
	,	a.rating
	,	p.rating
	,   a.price
	,	p.price
from app_store_apps as a
join play_store_apps p
using(name)
where a.rating > 4 and p.rating >4
order by a.rating desc,p.rating desc 



SELECT name, CAST(price as TEXT) as price
FROM app_store_apps
UNION ALL
SELECT  name, CAST(price as TEXT) as price
FROM play_store_apps
order by price DESC
limit 10

--primary query to get records price,rating,content_rating bgroup by genre
(select primary_genre,count(primary_genre) as tcount,CAST(price as numeric) as price,content_rating
from app_store_apps
group by primary_genre,price,content_rating
order by tcount desc
)
union
(select genres,count(genres) as tcount,Cast(REPLACE(TRIM(price),'$','') as NUMERIC) as price,content_rating
from play_store_apps
group by genres,price,content_rating
order by tcount desc
)
order by tcount desc


-- table-2 unique genres with sum of ratings based on genres got 119 rows
select round(avg(rating),1) as avg_rating,genres 
from play_store_apps 
where rating is not null
group by genres
order by avg_rating desc
--query ends

select distinct genres from play_store_apps --119
select distinct primary_genre from app_store_apps --23
select * from app_store_apps
select * from play_store_apps
--  table -1 unique list of records based on genres and their sum --23 rows
select round(avg(rating),1) as avg_rating,primary_genre 
from app_store_apps 
where rating is not null
group by primary_genre
order by avg_rating desc

--average rating by nearest 0.5
(select round(avg(rating),1) as avg_rating,genres 
from play_store_apps 
where rating is not null
group by genres
order by avg_rating desc
)
union
(
select round(avg(rating),1) as avg_rating,primary_genre 
from app_store_apps 
where rating is not null
group by primary_genre
order by avg_rating desc
)
order by desc avg_rating
--query to get common names with rating to calculate avg
select a.name,a.rating,p.name,p.rating --inner query to calculate total avg 
from app_store_apps as a
join
play_store_apps p
using(name)
where name ilike '%Roblox%'

select primary_genre ,
		sum(case when price = 0.00 then 10000 else
			   price*10000 end) as 
  price
from app_store_apps 
group by primary_genre
order by price desc
--query ends

--query based on rating
select name,content_rating from app_store_apps 
group by content_rating,name



-------------------------------------------------------
-- cte query
WITH combined_ratings AS (
    SELECT 
        name,
--        primary_genre,
        content_rating,
        rating as ar
    FROM 
        app_store_apps
    UNION
    SELECT 
        name,
--        genres,
        content_rating,
        rating as pr
    FROM 
        play_store_apps
)
SELECT 
    name,
--    genre,
    content_rating,
    AVG(rating+rating) AS average_rating
FROM 
    combined_ratings
	where rating is not null and name ilike '%Egg%'
GROUP BY 
    name, content_rating
ORDER BY 
    average_rating desc ;

------
select  a.name,a.rating,a.price,p.name,p.rating,p.price  
from app_store_apps as a
join play_store_apps p
using(name)
-------
    SELECT 
        name,
        rating,
        CAST(review_count AS INTEGER) AS r_count, 
        price AS app_price,  
        'app_store_apps' AS table_name
    FROM 
        app_store_apps
    WHERE 
        rating > 4.7
--	group by name,rating,review_count,price
	order by rating desc,
			 r_count desc
	limit 10

