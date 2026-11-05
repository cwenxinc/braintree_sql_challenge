/*
Q3: For the year 2012, create a 3 column, 1 row report showing the percent share of gdp_per_capita for the following regions: Asia, Europe, and the Rest of the World.
 */

-- column-wise presentation
WITH regions AS (
	SELECT
		c.continent_code, 
		p.country_code, 
		p.year, 
		p.gdp_per_capita, 
		CASE
			WHEN continent_code = 'AS' THEN 'Asia'
			WHEN continent_code = 'EU' THEN 'Europe'
			ELSE 'Rest of the World'
		END AS region
	FROM per_capita p
	JOIN continent_map_clean c ON p.country_code = c.country_code
	WHERE p.year = 2012 AND
		p.gdp_per_capita IS NOT NULL
),
region_gdp AS (
	SELECT
		region,
		SUM(gdp_per_capita) AS region_total
	FROM regions
	GROUP BY region
), 
total_gdp AS (
	SELECT
		SUM(region_total) AS total
	FROM region_gdp
)
SELECT
	region,
	ROUND(100 * (region_total / total), 2) AS percent_share
FROM region_gdp
CROSS JOIN total_gdp;

-- row-wise presentation
WITH regions AS ( -- restrict gdp to 2012 and aggregate countries into the requested regions
	SELECT
		c.continent_code, 
		p.country_code, 
		p.year, 
		p.gdp_per_capita, 
		CASE
			WHEN continent_code = 'AS' THEN 'Asia'
			WHEN continent_code = 'EU' THEN 'Europe'
			ELSE 'Rest of the World'
		END AS region
	FROM per_capita p
	JOIN continent_map_clean c ON p.country_code = c.country_code
	WHERE p.year = 2012 AND
		p.gdp_per_capita IS NOT NULL
), 
region_gdp AS ( -- calculate the total gdp for each region and across the world
	SELECT
		SUM(CASE WHEN region = 'Asia' THEN gdp_per_capita END) AS asia_gdp, 
		SUM(CASE WHEN region = 'Europe' THEN gdp_per_capita END) AS europe_gdp, 
		SUM(CASE WHEN region = 'Rest of the World' THEN gdp_per_capita END) AS rest_gdp, 
		SUM(gdp_per_capita) AS total_gdp
	FROM regions
)
SELECT
	CONCAT(ROUND(100 * (asia_gdp / total_gdp), 2), '%') AS 'Asia', 
	CONCAT(ROUND(100 * (europe_gdp / total_gdp), 2), '%') AS 'Europe', 
	CONCAT(ROUND(100 * (rest_gdp / total_gdp), 2), '%') AS 'Rest of World'
FROM region_gdp;
