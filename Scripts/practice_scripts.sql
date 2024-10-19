--query to find  price and profit for apps table 
select primary_genre,content_rating,
		case when price = 0.00 then 10000
			 when price > 0.00 then price*10000
else  price
end
from app_store_apps
group by primary_genre,price,content_rating


-- query to find price and profit  for table2  playstore

select name,content_rating,
case
/*		 when Cast(REPLACE(TRIM(price),'$','') as NUMERIC) = 0.00 then '10000'
		 when Cast(REPLACE(TRIM(price),'$','') as NUMERIC) > 0.00 then         Cast(REPLACE(TRIM(price),'$','') as NUMERIC)*10000
else  price */
		when  replace(price,'$','')::decimal =0 then '10000'
		else  (replace(price,'$','')::decimal*10000)::text
end
from play_store_apps
group by name,content_rating,price

-----------------------------------------------------
--merging 2 table queries ( price )
with combined_data as(
select  name
	,	content_rating
	,	primary_genre
	,	CAST(price AS NUMERIC) AS numeric_price  
	, 	rating
from app_store_apps
union all
select  name
	,	genres
    ,	content_rating
    ,   CAST(REPLACE(price, '$', '') AS DECIMAL) AS numeric_price
	,	rating
from  play_store_apps
),
adjusted_price as (

select name,content_rating,rating,-- as avg_rating,
		case when numeric_price = 0.00 then 10000
			 when numeric_price > 0.00 then numeric_price*10000
else  numeric_price
end 
from combined_data
--group by name,content_rating,numeric_price
)
select
name,content_rating,avg(rating),numeric_price
from adjusted_price
--where avg_rating is not null
--where name ilike '%Egg%'
group by name,content_rating,numeric_price
order by name 

--------------------------------------------------------------------

select name,content_rating,
		case when price = 0.00 then 10000
		else  price*10000

end adjusted_price
from app_store_apps
group by name,price,content_rating

union all

select name,content_rating,
case

		when replace(price,'$','')::decimal =0 then '10000'
		else (replace(price,'$','')::decimal*10000)::text
end adjusted_price
from play_store_apps
group by name,content_rating,price
-------------------------------------------------------------------------------------------
--- new analysis
WITH combined_ratings AS (
    SELECT 
        name,
        round(AVG(rating),1) AS average_rating
    FROM (
        SELECT 
            name,
            rating
        FROM 
            app_store_apps
        WHERE 
            rating IS NOT NULL
        UNION ALL
        SELECT 
            name,
            rating
        FROM 
            play_store_apps
        WHERE 
            rating IS NOT NULL
    ) AS all_ratings
    GROUP BY 
        name
)
SELECT 
    name,
    average_rating
FROM 
    combined_ratings
--	where name ilike '%Egg%'
ORDER BY 
    average_rating DESC;

-----------merging query to get name,reviewcount,price,rating desc by rating,review_count
(select a.name
	,	a.rating
	,	cast(a.price as numeric) as numeric_price  
	, 	cast(a.review_count as integer) as r_count
	,	'app_store_apps' AS table_name,
	(case when a.rating between 4.5 and 4.9 then 10
		 when a.rating between 5.0 and 5.4 then 11 
		 else 0
		 end )as applife_years,
	(case when a.rating between 4.5 and 4.9 then 10*4000*12
		  when a.rating between 5.0 and 5.4 then 11*4000*12
		  else 0
		  end) as annual_earnings,
	(case when a.price =0 then a.price+10000
			else a.price*10000
		  end) as adjusted_purchase_price,
	  -- calculate profit		  
	((CASE 							
        WHEN a.rating between 4.5 and 4.9 then 10*4000*12 
        WHEN a.rating between 5.0 and 5.4 then 11*4000*12 
        ELSE 0 
    END) - 
    (CASE 
        WHEN a.price = 0 THEN a.price + 10000 
        ELSE a.price * 10000 
    END)) AS profit		 
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
        when p.rating between 4.5 and 4.9 then 10*4000*12 
        when p.rating between 5.0 and 5.4 then 11*4000*12 
        else 0 
    end ) as annual_earnings,
    (case 
        when cast(replace(p.price, '$', '') as decimal)= 0.0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') as decimal) * 10000 
    end) as adjusted_purchase_price,
    -- calculate profit
    ((case 
        when p.rating between 4.5 and 4.9 then 10*4000*12 
        when p.rating between 5.0 and 5.4 then 11*4000*12 
        else 0 
    end) - 
    (case 
        when cast(replace(p.price, '$', '') AS decimal) = 0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') AS decimal) * 10000 
    end)) as profit
from  play_store_apps p
where 
rating >4.5
and name not in(select name from app_store_apps where rating > 4.5)
order by rating desc,
		 r_count desc
limit 10) --query ends here for play_store table

union all
------  ----------- join query for both tables common app names
--WITH price_comparison AS(
(SELECT  a.name
	,	ROUND(AVG(a.rating + p.rating)/2,2) as rating
	,	GREATEST(a.price,CAST(REPLACE(p.price, '$', '') AS DECIMAL)) as price
	,	greatest(p.review_count,cast(a.review_count as integer)) as r_count
--	,	p.review_count::integer as r_count
	,	'bothtables' as table_name,
	case 
        when ROUND(AVG(a.rating + p.rating)/2,2) = 4.5 then 10 
        when ROUND(AVG(a.rating + p.rating)/2,2) = 4.6 then 120/12--'10y 2 months=120 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.7 then 10--'10y 4 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.8 then 10--'10y 6 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 4.9 then 10--'10y 8 months'
		when ROUND(AVG(a.rating + p.rating)/2,2) = 5 then 11
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
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 10*4000*12 
        when ROUND(AVG(a.rating + p.rating)/2,2) between 5.0 and 5.4 then 11*4000*12 
        else 0 
    end) - 
    (case 
        when cast(replace(p.price, '$', '') AS decimal) = 0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') AS decimal) * 10000 
    end)) as profit
	
FROM app_store_apps  as a
INNER JOIN play_store_apps  p
ON a.name=p.name
--where ROUND(AVG(a.rating + p.rating)/2,2) >4.5
GROUP BY a.name,a.price,p.price,p.review_count,a.review_count
order by rating desc,
		 r_count desc
limit 10 )
--)
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





------------------------- philip inner join query
WITH price_comparison AS(
SELECT aps.name as aps_name,psa.name as psa_name,GREATEST( aps.price,CAST(REPLACE(psa.price, '$', '') AS DECIMAL)) as price, ROUND(AVG(aps.rating + psa.rating)/2,2) as avg_rating
FROM app_store_apps  as aps
INNER JOIN play_store_apps as psa
ON aps.name=psa.name
--where aps.name ILIKE '%Geometry Dash Lite%'
--and psa.name ILIKE '%Geo%'
GROUP BY aps.name,psa.name,aps.price,psa.price)
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













































































































--join of 2 tables common --rows 328
select a.name,sum(a.rating+pp.rating)/2 as average_rating
from app_store_apps as a
join play_store_apps pp
using(name)
group by a.name
order by average_rating desc
--left join rows --
select a.name,a.rating
from app_store_apps as a
left join play_store_apps pp
using(name)
where name not in (select name from play_store_apps)
group by a.name,a.rating
order by a.rating desc