# US HOUSEHOLD INCOME DATA EXPLORATION
/*

The goal of this project is to explore household income data across the US. 
I’m working with two tables:
- income: holds state, city, area size, and type of place (like city, borough, village, etc.)
- stats: holds income stats like mean and median household incomes.

The plan is to join the data, and then run some summaries to see where income levels are higher, how they vary by place type, and get a general sense of the data.
*/

SELECT * FROM income;
SELECT * FROM stats;

-- State land and water totals
SELECT State_Name, SUM(ALand), SUM(AWater)
FROM income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10;

-- Join income and stats, filter out invalid income data
SELECT * FROM income i
JOIN stats s 
	ON i.id = s.id
WHERE Mean <> 0;

-- Average income by state
SELECT i.State_Name, ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM income i
INNER JOIN stats s 
	ON i.id = s.id
WHERE Mean <> 0
GROUP BY i.State_Name
ORDER BY 2 DESC
LIMIT 10;

-- Income by place type
SELECT Type, COUNT(Type), ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM income i
INNER JOIN stats s 
	ON i.id = s.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 2 DESC 
LIMIT 20;

-- Same, but only for types with 100+ records

SELECT Type, COUNT(Type), ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM income i
INNER JOIN stats s 
	ON i.id = s.id
WHERE Mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 100
ORDER BY 2 DESC 
LIMIT 20;    #TYPES ARE city, tack, Borough, village, communities etc...

-- Look at "Community" type only (Puerto Rico)
SELECT *
FROM income
WHERE Type = 'Community';

-- Average and Median income by state and city
SELECT i.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM income i
JOIN stats s 
	ON i.id = s.id
GROUP BY i.State_Name, City
ORDER BY ROUND(AVG(Mean),1) DESC;
