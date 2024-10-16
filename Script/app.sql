SELECT *
FROM app_store_apps

SELECT *
FROM play_store_apps

(CTL+backslash to green whole query)

Select DISTINCT (aps.name),  MAX(aps. rating) as aps_rating,MAX (psa. rating) as psa_rating, aps.price,psa.price,
from app_store_apps as aps
inner join play_store_apps as psa
USING (name)
GROUP BY 1,4,5
ORDER BY 2 DESC,3 DESC
LIMIT 10

-- (SELECT name, ROUND(AVG(rating),2) AS avg_rating
-- FROM app_store_apps
-- GROUP BY name)
-- --ORDER BY avg_rating DESC)
-- UNION
-- (SELECT name, ROUND(AVG(rating),2) AS avg_rating
-- FROM play_store_apps
-- GROUP BY name
-- )--ORDER BY avg_rating DESC)
-- --WHERE avg_rating IS NOT NULL
-- ORDER BY avg_rating DESC
-- LIMIT 10
