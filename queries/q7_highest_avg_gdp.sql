/*
Q7a: Find the country with the highest average gdp_per_capita for each continent for all years.
 */

CREATE TABLE q7_results (
	WITH code_names AS (
		SELECT
			c1.continent_name, 
			m.country_code, 
			c2.country_name
		FROM continent_map m
		JOIN continents c1 ON m.continent_code = c1.continent_code
		JOIN countries c2 ON m.country_code = c2.country_code
	), 
	avg_gdp_ranks AS ( -- calculate the average gdp for each country across all years and rank it within its continent
		SELECT
			c.continent_name, 
			c.country_code, 
			c.country_name,
			AVG(p.gdp_per_capita) AS avg_gdp_per_capita, 
			RANK() OVER(
				PARTITION BY continent_name 
				ORDER BY AVG(p.gdp_per_capita) DESC) AS gdp_rank
		FROM per_capita p
		JOIN code_names c ON p.country_code = c.country_code
		GROUP BY c.continent_name, 
			c.country_code, 
			c.country_name
	)
	SELECT
		gdp_rank AS 'rank', -- add quotes around reserved word
		continent_name, 
		country_code,
		country_name,
		CONCAT('$', ROUND(avg_gdp_per_capita, 2)) AS 'avg_gdp_per_capita'
	FROM avg_gdp_ranks
	WHERE gdp_rank = 1 -- find the country that ranks first in its continent
);

/*
Q7b: Now compare your list to the following data set. Please describe any and all mistakes that you can find with the data set below. Include any code that you use to help detect these mistakes.
 */
	
/*
Visually inspecting the two tables reveals these mistakes in the reference table:
1. The country with the highest average GDP in Africa is Equatorial Guinea, not Seychelles;
2. The country with the highest average GDP in Asia is Qatar, not Kuwait.
3. Monaco is indeed the country that ranks first in Europe, but its actual average GDP should be $1,514.21 less than the stated amount.
4. Similar inaccuracies are found with Bermuda and Australia - the average GDP for Bermuda should be $84,634.83 instead of $83,788.48, and the average GDP for Australia should be $46,147.45 instead of $47,070.39.
 */

SELECT *
FROM q7_results;

/*
Alternatively, use a join to identify non-matching rows between the two tables:
 */

-- recreate the reference table with matching properties from the results table
CREATE TABLE q7_reference (
	`rank` BIGINT UNSIGNED NOT NULL, 
	continent_name VARCHAR(50), 
	country_code VARCHAR(50), 
	country_name VARCHAR(64), 
	avg_gdp_per_capita VARCHAR(23)
);

-- populate the reference table with the data provided
INSERT INTO q7_reference
VALUES 
	(1, 'Africa', 'SYC', 'Seychelles', '$11348.66'),
	(1, 'Asia', 'KWT', 'Kuwait', '$43192.49'), 
	(1, 'Europe', 'MCO', 'Monaco', '$152936.10'), 
	(1, 'North America', 'BMU', 'Bermuda', '$83788.48'), 
	(1, 'Oceania', 'AUS', 'Australia', '$47070.39'), 
	(1, 'South America', 'CHL', 'Chile', '$10781.71');

SELECT
	t1.rank, 
	t1.continent_name, 
	t1.country_code AS country_code_ref, 
	t2.country_code AS country_code_result, 
	t1.country_name AS country_name_ref, 
	t2.country_name AS country_name_result, 
	t1.avg_gdp_per_capita AS avg_gdp_per_capita_ref, 
	t2.avg_gdp_per_capita AS avg_gdp_per_capita_result
FROM q7_reference t1
LEFT JOIN q7_results t2
	ON t1.continent_name = t2.continent_name
WHERE 
	t1.country_code <> t2.country_code OR
	t1.country_name <> t2.country_name OR
	t1.avg_gdp_per_capita <> t2.avg_gdp_per_capita; -- South America is the only matching row so its record is excluded as expected
	
	