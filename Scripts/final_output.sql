SELECT  name
	,	rating
	,	price
	,	max(r_count) as r_count
 	,	table_name
	,	applife_years
	,	annual_earnings
	,	adjusted_purchase_price
	,	annual_profit
	,	applife_profit
FROM (
(SELECT  a.name
	,	round(2*((a.rating + p.rating)/2))/2 as rating
	,	GREATEST(a.price,CAST(REPLACE(p.price, '$', '') AS DECIMAL)) as price
	,	greatest(p.review_count,cast(a.review_count as integer)) as r_count
--	,	p.review_count::integer as r_count
	,	'bothtables' as table_name,
	case 
        when round(2*((a.rating + p.rating)/2))/2 = 4.5 then 10 
    	when round(2*((a.rating + p.rating)/2))/2 =5.0 then 11
        else 0 
    end AS applife_years,
	    (case 
        when round(2*((a.rating + p.rating)/2))/2 = 4.5  then 1*9000*12 
        when round(2*((a.rating + p.rating)/2))/2 = 5.0  then 1*9000*12 
        else 0 
    end ) as annual_earnings,
	(case 
        when cast(replace(p.price, '$', '') as decimal)= 0.0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') as decimal) * 10000 
    end) as adjusted_purchase_price,
	-- calculate profit
	((case 
        when round(2*((a.rating + p.rating)/2))/2 = 4.5  then 1*9000*12 
        when round(2*((a.rating + p.rating)/2))/2 = 5.0  then 1*9000*12 
        else 0 
    end) - 
    (case 
        when cast(replace(p.price, '$', '') AS decimal) = 0 then cast(replace(p.price, '$', '') AS decimal) + 10000 
        else cast(replace(p.price, '$', '') AS decimal) * 10000 
    end)) as annual_profit,
	(case 
        when round(2*((a.rating + p.rating)/2))/2 = 4.5  then 10*9000*12 
        when round(2*((a.rating + p.rating)/2))/2 = 5.0  then 11*9000*12 
        else 0 
    end ) as applife_profit
	
FROM app_store_apps  as a
INNER JOIN play_store_apps  p
ON a.name=p.name
--where ROUND(AVG(a.rating + p.rating)/2,2) >4.5
GROUP BY a.name,a.price,p.price,p.review_count,a.review_count,a.rating,p.rating
order by rating desc,
		 r_count desc
)
) a
group by name
	,	rating
	,	price
 	,	table_name
	,	applife_years
	,	annual_earnings
	,	adjusted_purchase_price
	,	annual_profit
	,	applife_profit
order by rating desc,
	 r_count desc
limit 10