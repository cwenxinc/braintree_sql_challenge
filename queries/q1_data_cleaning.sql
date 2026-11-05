/* 
Q1a: Alphabetically list all of the country codes in the continent_map table that appear more than once. Display any values where country_code is null as country_code = "FOO" and make this row appear first in the list, even though it should alphabetically sort to the middle
 */

-- properly format null values in country_code and continent_code
UPDATE continent_map
SET
	country_code = CASE WHEN country_code = '' THEN NULL ELSE country_code END,
	continent_code = CASE WHEN continent_code = '' THEN NULL ELSE continent_code END;

-- find countries with multiple records in continent_map, showing nulls at the top
SELECT
	IFNULL(country_code, 'FOO') AS repeated_country
FROM continent_map
GROUP BY country_code HAVING COUNT(*) > 1
ORDER BY country_code;

/* 
results from the query:

FOO
ARM
AZE
CYP
GEO
KAZ
RUS
TUR
UMI
 */


/*
Q1b: For all countries that have multiple rows in the continent_map table, delete all multiple records leaving only the 1 record per country. The record that you keep should be the first one when sorted by the continent_code alphabetically ascending.
 */

-- create a new table that has removed all duplicates from the records
CREATE TABLE continent_map_clean (
	WITH country_ordered AS (
		SELECT
			*, 
			ROW_NUMBER() OVER(
				PARTITION BY country_code 
				ORDER BY continent_code
			) AS row_num
		FROM continent_map
	)
	SELECT
		country_code, 
		continent_code
	FROM country_ordered
	WHERE row_num = 1
	ORDER BY country_code
);

SELECT *
FROM continent_map_clean;

/*
results from the query:

	AS
ABW	NA
AFG	AS
AGO	AF
AIA	NA
ALA	EU
ALB	EU
AND	EU
ANT	NA
ARE	AS
ARG	SA
ARM	AF
ASM	OC
ATA	AN
ATF	AN
ATG	NA
AUS	OC
AUT	EU
AZE	AS
BDI	AF
BEL	EU
BEN	AF
BES	NA
BFA	AF
BGD	AS
BGR	EU
BHR	AS
BHS	NA
BIH	EU
BLM	NA
BLR	EU
BLZ	NA
BMU	NA
BOL	SA
BRA	SA
BRB	NA
BRN	AS
BTN	AS
BVT	AN
BWA	AF
CAF	AF
...
 */

