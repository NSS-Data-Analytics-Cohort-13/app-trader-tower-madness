SELECT *
FROM app_store_apps

SELECT*
FROM play_store_apps


SELECT
		a.name
	,	a.price
	,	CAST(REPLACE(p.price, '$', '') AS NUMERIC)
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
-----------------------------------------------------------------------------------------
--avg price with prev query

SELECT
		a.name
	,	ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2) AS avg_price
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name
ORDER BY avg_price	
-----------------------------------------------------------------------------------------
--ADD review count round to nearest .5

SELECT
		ROUND(AVG(a.rating + p.rating)/2,0) AS avg_rating
	,	a.name
	,	ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2) AS avg_price
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.rating, p.rating
ORDER BY avg_price DESC, avg_rating DESC
-----------------------------------------------------------------------------------------
--add where statement where avg_rating>4.5 and avg price =1 and 0 showing shelf life

SELECT
		ROUND(AVG(p.review_count +	CAST(a.review_count AS INTEGER)),2) AS avg_reviews
	,	a.primary_genre
	,	a.content_rating
	,	p.content_rating
	,	ROUND(ROUND(a.rating + p.rating),0)/2 AS avg_rating
	,	a.name
	,	ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2) AS avg_price
	,	(CASE WHEN ROUND(AVG(a.rating + p.rating)/2,0)=5 THEN 'predicted life 11 years'
			  WHEN ROUND(AVG(a.rating + p.rating)/2,0)=4 THEN 'predicted life 9 years' 
			  WHEN ROUND(AVG(a.rating + p.rating)/2,0)=3 THEN 'predicted life 7 years'
			  WHEN ROUND(AVG(a.rating + p.rating)/2,0)=2 THEN 'predicted life 5 years'
			  WHEN ROUND(AVG(a.rating + p.rating)/2,0)=1 THEN 'predicted life 3 years'
			  WHEN ROUND(AVG(a.rating + p.rating)/2,0)=0 THEN 'predicted life 1 years'
			  END) AS condition1
	,	(CASE WHEN ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)<1 THEN '10000'
			  WHEN ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)=0 THEN '10000' ELSE 'too expensive' END) AS Conditions2
	,	(CASE WHEN ROUND(AVG(a.price + CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)<=1 	THEN 'Recommended Purchase' 
			WHEN ROUND(AVG(a.price + CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)=0 THEN 'Recommended Purchase' 
			WHEN ROUND(AVG(a.rating + p.rating)/2,0)=5 THEN 'Recommended Purchase' ELSE 'Not Recommended' END) AS Recommendations
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
	WHERE p.content_rating='Everyone'
GROUP BY a.name, a.rating, p.rating, a.price, p.price, a.primary_genre, a.content_rating, p.content_rating, a.review_count, p.review_count
ORDER BY avg_price ASC, avg_rating DESC, avg_reviews DESC
---------------------------------------------------------------------------------------
--phillip formula

WITH price_comparison AS(
SELECT aps.name as aps_name,psa.name as psa_name,GREATEST( aps.price,CAST(REPLACE(psa.price, '$', '') AS DECIMAL)) as price, ROUND((aps.rating + psa.rating)/2,1) as avg_rating
FROM app_store_apps  as aps
INNER JOIN play_store_apps as psa
ON aps.name=psa.name
--where aps.name ILIKE '%Geometry Dash Lite%'
--and psa.name ILIKE '%Geo%'
GROUP BY aps.name,psa.name,aps.price,psa.price,aps.rating,psa.rating)
SELECT aps_name,
	   psa_name,
	   price,
	   avg_rating,
	 
	   CASE WHEN price = 0 THEN price + 10000
	   		WHEN price <= 1.00 then price *10000
			WHEN price >= 1.00 THEN price *10000
			END as Purchase_Price,
			9000 as Monthly_Revenue,
		CASE
		 WHEN avg_rating >= 4.7 and price = 0.00
		 THEN 'advisable purchase'
		 ELSE 'not recommended'
		 END as Purchase_recommendation
FROM price_comparison
ORDER BY avg_rating DESC
-------------------------------------------------------------------------------------------
--praveena crazy scientist formula

(select a.name
	,	a.rating
	,	cast(a.price as numeric) as numeric_price
	, 	cast(a.review_count as integer) as r_count
	,	'app_store_apps' AS table_name,
	(case when a.rating between 4.5 and 4.9 then 10
		 when a.rating between 5.0 and 5.4 then 11
		 else 0
		 end )as applife_years,
	(case when a.rating between 4.5 and 4.9 then 1*4000*12
		  when a.rating between 5.0 and 5.4 then 1*4000*12
		  else 0
		  end) as annual_earnings,
	(case when a.price =0 then a.price+10000
			else a.price*10000
		  end) as adjusted_purchase_price,
	  -- calculate profit		 
	((CASE 							
        WHEN a.rating between 4.5 and 4.9 then 1*4000*12
        WHEN a.rating between 5.0 and 5.4 then 1*4000*12
        ELSE 0
    END) -
    (CASE
        WHEN a.price = 0 THEN a.price + 10000
        ELSE a.price * 10000
    END)) AS annual_profit	,
	(case
        when a.rating between 4.5 and 4.9 then 10*4000*12
        when a.rating between 5.0 and 5.4 then 11*4000*12
        else 0
    end ) as applife_profit
from app_store_apps a
where
rating >4.5
and name not in (select name FROM play_store_apps where rating > 4.5)
order by rating desc,
		 r_count desc
limit 10) --query ends here for app_store table
union all
--query starts here for play_store table
(select p.name
	,	p.rating
    ,   cast(replace(p.price, '$', '') AS decimal) as numeric_price
	,	p.review_count::integer as r_count
	,	'play_store_apps' as table_name,
	case
        when p.rating between 4.5 and 4.9 then 10
        when p.rating between 5.0 and 5.4 then 11
        else 0
    end AS applife_years,
    (case
        when p.rating between 4.5 and 4.9 then 1*4000*12
        when p.rating between 5.0 and 5.4 then 1*4000*12
        else 0
    end ) as annual_earnings,
    (case
        when cast(replace(p.price, '$', '') as decimal)= 0.0 then cast(replace(p.price, '$', '') AS decimal) + 10000
        else cast(replace(p.price, '$', '') as decimal) * 10000
    end) as adjusted_purchase_price,
    -- calculate profit
    ((case
        when p.rating between 4.5 and 4.9 then 1*4000*12
        when p.rating between 5.0 and 5.4 then 1*4000*12
        else 0
    end) -
    (case
        when cast(replace(p.price, '$', '') AS decimal) = 0 then cast(replace(p.price, '$', '') AS decimal) + 10000
        else cast(replace(p.price, '$', '') AS decimal) * 10000
    end)) as annual_profit,
	(case
        when p.rating between 4.5 and 4.9 then 10*4000*12
        when p.rating between 5.0 and 5.4 then 11*4000*12
        else 0
    end ) as applife_profit
from  play_store_apps p
where
rating >4.5
and name not in(select name from app_store_apps where rating > 4.5)
order by rating desc,
		 r_count desc
limit 10) --query ends here for play_store table
union all
------  ----------- join query for both tables common app names
(SELECT  a.name
	,	ROUND(AVG(a.rating + p.rating)/2,1) as rating
	,	GREATEST(a.price,CAST(REPLACE(p.price, '$', '') AS DECIMAL)) as price
	,	greatest(p.review_count,cast(a.review_count as integer)) as r_count
--	,	p.review_count::integer as r_count
	,	'bothtables' as table_name,
	case
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 10
    /*    when ROUND(AVG(a.rating + p.rating)/2,2) = 4.6 then 10--.1--122 / 12--'10y 2 months=120 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.7 then 10--.3--124/12--'10y 4 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.8 then 10--.5--26/12--'10y 6 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.9 then 10--.6--128/12--'10y 8 months' */
		when ROUND(AVG(a.rating + p.rating)/2,2) between 5.0 and 5.4 then 11
        else 0
    end AS applife_years,
	    (case
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 1*9000*12
        when ROUND(AVG(a.rating + p.rating)/2,2) between 5.0 and 5.4 then 1*9000*12
        else 0
    end ) as annual_earnings,
	(case
        when cast(replace(p.price, '$', '') as decimal)= 0.0 then cast(replace(p.price, '$', '') AS decimal) + 10000
        else cast(replace(p.price, '$', '') as decimal) * 10000
    end) as adjusted_purchase_price,
	-- calculate profit
	((case
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 1*9000*12
        when ROUND(AVG(a.rating + p.rating)/2,2) between 5.0 and 5.4 then 1*9000*12
        else 0
    end) -
    (case
        when cast(replace(p.price, '$', '') AS decimal) = 0 then cast(replace(p.price, '$', '') AS decimal) + 10000
        else cast(replace(p.price, '$', '') AS decimal) * 10000
    end)) as annual_profit,
	(case
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 10*9000*12
        when ROUND(AVG(a.rating + p.rating)/2,2) between 5.0 and 5.4 then 11*9000*12
        else 0
    end ) as applife_profit
	
FROM app_store_apps  as a
INNER JOIN play_store_apps  p
ON a.name=p.name
--where ROUND(AVG(a.rating + p.rating)/2,2) >4.5
GROUP BY a.name,a.price,p.price,p.review_count,a.review_count
order by rating desc,
		 r_count desc
limit 25 )
----------------------------------------------------------------------------------------
SELECT
		ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)AS avg_price
	,	a.name
	,	a.primary_genre
	,	ROUND(AVG((CAST(a.review_count AS INTEGER) + CAST(p.review_count AS INTEGER))/2.0),2) AS avg_count
	,	ROUND(ROUND(a.rating + p.rating),0)/2 AS avg_rating
	,	a.primary_genre
	,	COUNT(*) AS genre_count
	,	ROUND((COUNT(*) * 100.0) / SUM(COUNT(*)) OVER (), 2) AS genre_percentage
	,	(CASE WHEN ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)<1 THEN 10000
			   WHEN ROUND(AVG((CAST(REPLACE(a.price::TEXT, '$', '') AS NUMERIC) + CAST(REPLACE(p.price::TEXT, '$', '') AS NUMERIC))/2),2)<2 THEN 10000
			   ELSE NULL END) AS total_price
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.primary_genre, a.rating, p.rating
ORDER by avg_rating DESC, avg_count DESC, genre_count DESC






