/*
Q5: Find the sum of gdp_per_capita by year and the count of countries for each year that have non-null gdp_per_capita where (i) the year is before 2012 and (ii) the country has a null gdp_per_capita in 2012.
 */

-- the question can be broken down into two steps:
-- restrict to countries with null gdp in 2012
-- then for each year before 2012, count countries with non-null gdp and sum their gdps

WITH null_countries AS ( -- identify countries with a null gdp in 2012
	SELECT country_code
	FROM per_capita
	WHERE year = 2012 AND 
		gdp_per_capita IS NULL
)
SELECT
	p.year, 
	COUNT(p.gdp_per_capita) AS country_count, -- count only countries with a gdp recorded
	CONCAT('$', ROUND(SUM(p.gdp_per_capita), 2)) AS total
FROM per_capita p
JOIN null_countries n ON p.country_code = n.country_code -- use a join to filter for qualifying countries
WHERE p.year < 2012 -- only consider years before 2012 as requested
GROUP BY p.year
ORDER BY p.year;