# WORLD LIFE EXPECTANCY PROJECT (DATA EXPLORATION)

/*

Summary:
The goal of this project is to explore global life expectancy data. 
I analyzed life expectancy trends over time, across countries, and in relation to GDP, BMI, adult mortality, and development status (Developed vs Developing).
This helps identify patterns and relationships that may impact life expectancy across different regions and income levels.
*/

SELECT *
FROM World_Life.life_expe;

-- Min and max life expectancy by country (initial check)
SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`)
FROM World_Life.life_expe
GROUP BY Country DESC;

-- Calculate life expectancy increase over time for each country
SELECT Country,
MIN(`Life expectancy`),
MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS life_Increase_15_Years
FROM World_Life.life_expe
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Country ASC ;

-- Average life expectancy per year across all countries
SELECT Year, ROUND(AVG(`Life expectancy`), 2)
FROM World_Life.life_expe
WHERE `Life expectancy` <> 0
AND MAX(`Life expectancy`) <> 0
GROUP BY Year
ORDER BY Year;

-- Average life expectancy and GDP per country
SELECT Country, ROUND(AVG(`Life expectancy`), 1) AS life_exp, ROUND(AVG(GDP), 1) AS GDP
FROM World_Life.life_expe
GROUP BY Country
HAVING life_exp <> 0
AND GDP <> 0
ORDER BY GDP ASC;

-- Compare life expectancy for high and low GDP groups
SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Count,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Count
FROM World_Life.life_expe;

-- Average life expectancy by status (Developed vs Developing)
SELECT Status, ROUND(AVG(`Life expectancy`), 1)
FROM World_Life.life_expe
GROUP BY Status;

-- Count of countries per status and their average life expectancy
SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`), 1)
FROM World_Life.life_expe
GROUP BY Status;

-- Average life expectancy and BMI by country
SELECT Country, ROUND(AVG(`Life expectancy`), 1) AS life_exp, ROUND(AVG(BMI), 1) AS BMI
FROM World_Life.life_expe
GROUP BY Country
HAVING BMI <> 0
AND life_exp <> 0
ORDER BY BMI DESC;

-- Rolling total of adult mortality for USA across years
SELECT Country, 
Year, 
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM World_Life.life_expe
WHERE Country = 'United States of America';


