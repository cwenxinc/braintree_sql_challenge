/*
Q4a: What is the count of countries and sum of their related gdp_per_capita values for the year 2007 where the string 'an' (case insensitive) appears anywhere in the country name?
 */

SELECT
	COUNT(c.country_name) AS country_count, 
	CONCAT('$', ROUND(SUM(p.gdp_per_capita), 2)) AS gdp_sum
FROM per_capita p
JOIN countries c ON p.country_code = c.country_code
WHERE p.year = 2007 AND
	c.country_name LIKE '%an%'; -- search for countries that have 'an' (case-insensitive) anywhere in their names
	
/*
Q4b: Repeat question 4a, but this time make the query case sensitive.
 */
	
SELECT
	COUNT(c.country_name) AS country_count, 
	CONCAT('$', ROUND(SUM(p.gdp_per_capita), 2)) AS gdp_sum
FROM per_capita p 
JOIN countries c ON p.country_code = c.country_code
WHERE p.year = 2007 AND
	REGEXP_LIKE(c.country_name, '.*an.*', 'c'); -- 'c' forces case-sensitive restriction