/*
Q2: List the countries ranked 10-12 in each continent by the percent of year-over-year growth descending from 2011 to 2012.
 */

WITH gdp AS ( -- restrict to the gdp per capita from 2011-2012
	SELECT
		*, 
		gdp_per_capita AS gdp_2011,
		LEAD(gdp_per_capita) OVER(PARTITION BY country_code ORDER BY year) AS gdp_2012
	FROM per_capita
	WHERE year BETWEEN 2011 AND 2012
), 
growth AS ( -- calculate the percent of growth for each country
	SELECT
		country_code, 
		100 * ((gdp_2012 - gdp_2011) / gdp_2011) AS growth_percent
	FROM gdp
	WHERE gdp_2011 IS NOT NULL AND
		gdp_2012 IS NOT NULL
), 
growth_rank AS ( -- rank each country within its continent by its percent of growth in descending order
	SELECT
		c.country_code, 
		c.continent_code, 
		g.growth_percent,
		RANK() OVER(PARTITION BY c.continent_code ORDER BY g.growth_percent DESC) AS country_rank
	FROM continent_map_clean c
	JOIN growth g ON c.country_code = g.country_code
)
SELECT -- retain only those countries ranked 10-12 within their continent and connect the continent and country codes to their corresponding names
	r.country_rank AS 'rank', 
	c1.continent_name, 
	r.country_code, 
	c2.country_name,
	CONCAT(ROUND(r.growth_percent, 2), '%') AS growth_percent
FROM growth_rank r
JOIN continents c1 ON r.continent_code = c1.continent_code
JOIN countries c2 ON r.country_code = c2.country_code
WHERE r.country_rank BETWEEN 10 AND 12
ORDER BY c1.continent_name, r.growth_percent DESC;

/*
results from the query:
10	Africa	RWA	Rwanda	8.73
11	Africa	GIN	Guinea	8.32
12	Africa	NGA	Nigeria	8.09
10	Asia	UZB	Uzbekistan	11.12
11	Asia	IRQ	Iraq	10.06
12	Asia	PHL	Philippines	9.73
...
 */

