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
		ROUND(AVG(a.rating + p.rating)/2,0) AS avg_rating
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
			  WHEN ROUND(AVG(a.price +	CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)=0 THEN '10000' END) AS Conditions2
	,	(CASE WHEN ROUND(AVG(a.price + CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)<=1 	THEN 'Recommended Purchase' 
			WHEN ROUND(AVG(a.price + CAST(REPLACE(p.price, '$', '') AS NUMERIC)),2)=0 THEN 'Recommended Purchase' 
			WHEN ROUND(AVG(a.rating + p.rating)/2,0)=5 THEN 'Recommended Purchase' END) AS Recommendations
FROM app_store_apps AS a
	INNER JOIN play_store_apps AS p
		ON a.name=p.name
GROUP BY a.name, a.rating, p.rating, a.price, p.price
ORDER BY avg_price ASC, avg_rating DESC
---------------------------------------------------------------------------------------

