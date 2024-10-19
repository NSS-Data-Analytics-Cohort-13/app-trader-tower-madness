WITH app_calculations AS (
    select a.name
	,	a.rating
	,	cast(a.price as numeric) as numeric_price  
	, 	cast(a.review_count as integer) as r_count
	,	'app_store_apps' AS table_name,
	(case when a.rating =4.5 then 10
		 when a.rating =5.0 then 11 
		 else 0
		 end )as applife_years,
	(case when a.rating=4.5 then 10*4000*12
		  when a.rating=5.0 then 11*4000*12
		  else 0
		  end) as annual_earnings,
	(case when a.price =0 then a.price+10000
			else a.price*10000
		  end) as adjusted_purchase_price,
	  -- calculate profit		  
	((CASE 							
        WHEN a.rating = 4.5 THEN 10*4000*12 
        WHEN a.rating = 5.0 THEN 11*4000*12 
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
limit 10
),
play_calculations AS (
    select p.name
	,	p.rating
    ,   cast(replace(p.price, '$', '') AS decimal) as numeric_price
	,	p.review_count::integer as r_count
	,	'play_store_apps' as table_name,
	case 
        when p.rating = 4.5 then 10 
        when p.rating = 5.0 then 11 
        else 0 
    end AS applife_years,
    (case 
        when p.rating = 4.5 then 10*4000*12 
        when p.rating = 5.0 then 11*4000*12 
        else 0 
    end ) as annual_earnings,
    (case 
        when cast(replace(p.price, '$', '') as decimal)= 0.0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') as decimal) * 10000 
    end) as adjusted_purchase_price,
    -- calculate profit
    ((case 
        when p.rating = 4.5 then 10*4000*12 
        when p.rating = 5.0 then 11*4000*12 
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
limit 10
),
overlapping_apps AS (
    SELECT  a.name
	,	ROUND(AVG(a.rating + p.rating)/2,1) as rating
	,	GREATEST(a.price,CAST(REPLACE(p.price, '$', '') AS DECIMAL)) as price
	,	greatest(p.review_count,cast(a.review_count as integer)) as r_count
--	,	p.review_count::integer as r_count
	,	'bothtables' as table_name,
	case 
        when ROUND(AVG(a.rating + p.rating)/2,2) between 4.5 and 4.9 then 10 
   
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
limit 10 
)

-- Unique apps from app_store_apps
(SELECT 
    name,
    rating,
    numeric_price,
    r_count,
    app_life_years,
    annual_profit,
    adjusted_price,
--    'app_store_apps' AS table_name
FROM 
    app_calculations a
WHERE 
    name NOT IN (SELECT name FROM overlapping_apps)
ORDER BY 
    rating DESC,
    r_count DESC
LIMIT 10)

UNION ALL

-- Unique apps from play_store_apps
(SELECT 
    name,
    rating,
    numeric_price,
    r_count,
    app_life_years,
    annual_profit,
    adjusted_price,
--    'play_store_apps' AS table_name
FROM 
    play_calculations p
WHERE 
    name NOT IN (SELECT name FROM overlapping_apps)
ORDER BY 
    rating DESC,
    r_count DESC
LIMIT 10)

UNION ALL

-- Apps that exist in both tables
(SELECT 
    a.name,
    a.rating,
    a.numeric_price,
    a.r_count,
    CASE 
        WHEN a.rating = 4.5 THEN 10 
        WHEN a.rating = 5.0 THEN 11 
        ELSE 0 
    END AS app_life_years,
    (CASE 
        WHEN a.rating = 4.5 THEN 10 
        WHEN a.rating = 5.0 THEN 11 
        ELSE 0 
    END * 4000 * 12) AS annual_profit,
    (CASE 
        WHEN a.price = 0 THEN a.price + 10000 
        ELSE a.price * 10000 
    END) AS adjusted_price,
    'both' AS table_name
FROM 
    app_calculations a
JOIN 
    play_calculations p ON a.name = p.name
ORDER BY 
    a.rating DESC,
    a.r_count DESC
)