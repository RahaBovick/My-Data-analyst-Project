# US HOUSEHOLD INCOME DATA CLEANING

SELECT * FROM income;
SELECT * FROM stats;

-- Count Rows in each Tables
SELECT COUNT(id) FROM income;
SELECT COUNT(id) FROM stats;

-- Check for duplicate IDs in income table (6 Duplicates found)
SELECT id, COUNT(id) FROM income
GROUP BY id
HAVING COUNT(id)> 1;

-- Find row IDs of duplicate records in income table
SELECT row_id
	FROM(
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM income
) Duplicates
WHERE row_num > 1;

-- Delete duplicate rows from income table
DELETE FROM income
WHERE row_id IN (
	SELECT row_id
	FROM(
	SELECT row_id,
	id,
	ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM income
) Duplicates
WHERE row_num > 1);

-- Check for duplicates in stats table (none found)
SELECT id, COUNT(id) FROM stats
GROUP BY id
HAVING COUNT(id)> 1;  

SELECT DISTINCT State_Name FROM income
ORDER BY 1
;

-- Fix typo: 'georia' → 'Georgia'
UPDATE income
SET State_Name = 'Georgia'
WHERE State_Name = 'georia';

-- Fix typo: 'alabama' → 'Alabama'
UPDATE income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

-- Check rows for Autauga County to verify place names
SELECT * FROM income
WHERE County = 'Autauga County'
ORDER BY 1;

-- Fix wrong place name in Autauga County
UPDATE income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';

-- Check place types for consistency
SELECT Type, COUNT(Type)
FROM income
GROUP BY Type;

-- Fix typo: 'Boroughs' → 'Borough'
UPDATE income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

-- Check for rows where both land and water area are missing or zero
SELECT ALand, AWater
FROM income
WHERE (AWater = 0 OR AWater = '' OR AWater IS NULL)
AND (ALand = 0 OR ALand = '' OR AWater IS NULL);