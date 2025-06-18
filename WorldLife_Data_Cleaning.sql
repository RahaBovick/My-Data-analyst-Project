# WORLD LIFE EXPECTANCY PROJECT (DATA CLEANING)

/*

Summary:
The goal of this step was to clean the World Life Expectancy dataset.
- Removed duplicate records.
- Standardized missing Status values.
- Filled missing life expectancy values using neighbor years' averages.

*/


SELECT *
FROM World_Life.life_expe;

# Check for duplicates based on Country and Year
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM World_Life.life_expe
GROUP BY Country, Year,CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

# Identify duplicate rows using ROW_NUMBER()
SELECT *
FROM (
SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
FROM World_Life.life_expe
) AS row_table
WHERE row_num > 1;

# Delete duplicate rows based on Row_ID
SELECT *
FROM (
SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
FROM World_Life.life_expe
) AS row_table
WHERE row_num > 1;

DELETE FROM World_Life.life_expe
WHERE Row_ID IN (SELECT Row_ID
FROM (
SELECT Row_ID, 
CONCAT(Country, Year),
ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS row_num
FROM World_Life.life_expe
) AS row_table
WHERE row_num > 1
);

# Check distinct Status values
SELECT DISTINCT(Status)
FROM World_Life.life_expe
WHERE Status <> '';

# Confirm which countries are marked as Developing
SELECT DISTINCT(Country)
FROM World_Life.life_expe
WHERE Status = 'Developing';

# Update records where Status is blank but country belongs to Developing group
UPDATE World_Life.life_expe
SET Status = 'Developing'
WHERE Country IN (SELECT DISTINCT(Country)
			FROM World_Life.life_expe
			WHERE Status = 'Developing');
            
UPDATE World_Life.life_expe t1
JOIN World_Life.life_expe t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

UPDATE World_Life.life_expe t1
JOIN World_Life.life_expe t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';

# Check for rows where Life Expectancy is blank
SELECT *
FROM World_Life.life_expe
WHERE `Life expectancy`= '';

# Preview interpolation candidates: fill missing Life Expectancy by averaging previous and next year
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
FROM World_Life.life_expe t1
JOIN World_Life.life_expe t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN World_Life.life_expe t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

# Apply interpolation to fill missing Life Expectancy values
UPDATE World_Life.life_expe t1
JOIN World_Life.life_expe t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year -1
JOIN World_Life.life_expe t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy`= ''
;





