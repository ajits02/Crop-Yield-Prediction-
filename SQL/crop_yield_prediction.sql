SELECT * FROM crop_yield.crop_yield;

-- Analysis through Questions ;

-- 1. Which crops have the highest average yield?

SELECT Crop, AVG(Yield) AS avg_yield
FROM crop_yield.crop_yield
GROUP BY Crop
ORDER BY avg_yield DESC
LIMIT 10;

-- 2. Which states produce the most total agricultural output?

SELECT State, SUM(Production) AS total_production
FROM crop_yield.crop_yield
GROUP BY State
ORDER BY total_production DESC
LIMIT 10;

-- 3.  Are there any records with missing/null values in key columns?

SELECT *
FROM crop_yield.crop_yield
WHERE Crop IS NULL
   OR Crop_Year IS NULL
   OR State IS NULL
   OR Area IS NULL
   OR Production IS NULL
   OR Yield IS NULL;

-- 4. Which crop had the most volatile yield across years (highest standard deviation)?

SELECT Crop, STDDEV(Yield) AS yield_std_dev
FROM crop_yield.crop_yield
GROUP BY Crop
ORDER BY yield_std_dev DESC
LIMIT 10;

-- 5. Find year-over-year growth in yield for each crop

SELECT 
    Crop, 
    Crop_Year, 
    Yield,
    LAG(Yield) OVER (PARTITION BY Crop ORDER BY Crop_Year) AS previous_year_yield,
    ROUND(((Yield - LAG(Yield) OVER (PARTITION BY Crop ORDER BY Crop_Year)) /
           LAG(Yield) OVER (PARTITION BY Crop ORDER BY Crop_Year)) * 100, 2) AS yoy_growth_percent
FROM crop_yield.crop_yield
ORDER BY Crop, Crop_Year;


-- 6. Top 5 crops by yield in each state

SELECT *
FROM (
    SELECT 
        State,
        Crop,
        AVG(Yield) AS avg_yield,
        ROW_NUMBER() OVER (PARTITION BY State ORDER BY AVG(Yield) DESC) AS rn
    FROM crop_yield.crop_yield
    GROUP BY State, Crop
) ranked
WHERE rn <= 5;

-- 7. Which crops are grown in the most number of states?

SELECT Crop, COUNT(DISTINCT State) AS state_count
FROM crop_yield.crop_yield
GROUP BY Crop
ORDER BY state_count DESC;

-- 8. Calculate yield per hectare (if not already calculated)

SELECT *,
       CASE 
           WHEN Area > 0 THEN ROUND(Production / Area, 2)
           ELSE NULL
       END AS yield_per_hectare
FROM crop_yield.crop_yield;

-- 9. What is the average yield trend over the years for all crops combined?

SELECT Crop_Year, 
       ROUND(AVG(Yield), 2) AS avg_yield_across_all_crops
FROM crop_yield.crop_yield
GROUP BY Crop_Year
ORDER BY Crop_Year;

-- 10. Which state-crop combinations had the highest pesticide usage per hectare?

SELECT State, Crop,
       SUM(Pesticide) AS total_pesticide,
       SUM(Area) AS total_area,
       ROUND(SUM(Pesticide) / NULLIF(SUM(Area), 0), 2) AS pesticide_per_hectare
FROM crop_yield.crop_yield
WHERE Pesticide IS NOT NULL AND Area > 0
GROUP BY State, Crop
ORDER BY pesticide_per_hectare DESC
LIMIT 10;


