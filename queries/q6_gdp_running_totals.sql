WITH code_names AS (
	SELECT
		c1.continent_name, 
		m.country_code, 
		c2.country_name
	FROM continent_map m
	JOIN continents c1 ON m.continent_code = c1.continent_code
	JOIN countries c2 ON m.country_code = c2.country_code
), 
gdp_2009 AS (
	SELECT -- Q6a: Create a single list of all per_capita records for year 2009 that includes columns continent_name, country_code, country_name, and gdp_per_capita.
		c.*, 
		p.gdp_per_capita
	FROM per_capita p
	JOIN code_names c ON p.country_code = c.country_code
	WHERE p.year = 2009 AND
		p.gdp_per_capita
), 
gdp_running_totals AS (
	SELECT
		*, 
		SUM(gdp_per_capita) OVER(
			PARTITION BY continent_name 
			ORDER BY continent_name, -- Q6b: Order this list by continent_name ascending and characters 2 through 4 (inclusive) of country_name descending.
				SUBSTRING(country_name, 2, 3) DESC
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total -- Q6c: Create a running total of gdp_per_capita by continent_name.
	FROM gdp_2009
), 
running_totals_ordered AS (
	SELECT
		*, 
		ROW_NUMBER() OVER( -- order the running total records that meet or exceed $70,000.00 within each continent
			PARTITION BY continent_name 
			ORDER BY running_total)	AS row_num
	FROM gdp_running_totals
	WHERE running_total > 70000
)
SELECT
	continent_name, 
	country_code, 
	country_name, 
	CONCAT('$', ROUND(gdp_per_capita, 2)) AS 'gdp_per_capita', 
	CONCAT('$', ROUND(running_total, 2)) AS 'running_total'
FROM running_totals_ordered
WHERE row_num = 1; -- Q6d: Return only the first record from the ordered list for which each continent's running total of gdp_per_capita meets or exceeds $70,000.00 with the following columns: continent_name, country_code, country_name, gdp_per_capita, running_total.