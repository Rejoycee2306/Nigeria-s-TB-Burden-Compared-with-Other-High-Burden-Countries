CREATE DATABASE TB_burden_analysis;
USE TB_burden_analysis;
-- Importing tables into database
SELECT COUNT(*) FROM tb_burden_estimates;
SELECT COUNT(*) FROM tb_burden_estimates WHERE case_detection_pct = '';
SELECT * FROM tb_burden_estimates WHERE iso3 = 'NGA' ORDER BY year;
UPDATE tb_burden_estimates SET case_detection_pct = NULL WHERE case_detection_pct = '';
ALTER TABLE tb_burden_estimates
MODIFY COLUMN iso3 VARCHAR(3),
MODIFY COLUMN country VARCHAR(100),
MODIFY COLUMN who_region VARCHAR(10),
MODIFY COLUMN case_detection_pct DOUBLE;
SELECT COUNT(*) FROM tb_burden_estimates WHERE case_detection_pct IS NULL;

SELECT COUNT(*) FROM mdr_rr_burden_estimates;
SELECT COUNT(*) FROM mdr_rr_burden_estimates WHERE rr_pct_new = '';
UPDATE mdr_rr_burden_estimates SET rr_pct_new = NULL WHERE rr_pct_new = '';
UPDATE mdr_rr_burden_estimates SET rr_pct_retreated = NULL WHERE rr_pct_retreated = '';
UPDATE mdr_rr_burden_estimates SET rr_cases_est = NULL WHERE rr_cases_est = '';
ALTER TABLE mdr_rr_burden_estimates
MODIFY COLUMN iso3 VARCHAR(3),
MODIFY COLUMN rr_pct_new DOUBLE,
MODIFY COLUMN rr_pct_retreated DOUBLE,
MODIFY COLUMN rr_cases_est INT;

SELECT COUNT(*) FROM treatment_outcomes;
SELECT COUNT(*) FROM treatment_outcomes WHERE new_cohort = '';
UPDATE treatment_outcomes SET new_cohort = NULL WHERE new_cohort = '';
UPDATE treatment_outcomes SET new_success = NULL WHERE new_success = '';
UPDATE treatment_outcomes SET new_succ_rate_pct = NULL WHERE new_succ_rate_pct = '';
UPDATE treatment_outcomes SET mdr_cohort = NULL WHERE mdr_cohort = '';
UPDATE treatment_outcomes SET mdr_success = NULL WHERE mdr_success = '';
ALTER TABLE treatment_outcomes
MODIFY COLUMN iso3 VARCHAR(3),
MODIFY COLUMN new_cohort INT,
MODIFY COLUMN new_success INT,
MODIFY COLUMN new_succ_rate_pct DOUBLE,
MODIFY COLUMN mdr_cohort INT,
MODIFY COLUMN mdr_success INT;
SELECT COUNT(*) FROM treatment_outcomes WHERE new_cohort IS NULL;
SELECT * FROM treatment_outcomes WHERE iso3 = 'NGA' ORDER BY year DESC;

-- Analysis
-- 1. Find the high burden countries (top 30) by estimated absolute no of incident cases 
SELECT * FROM tb_burden_estimates
WHERE year = 2024
ORDER BY incident_cases DESC
LIMIT 20;

SELECT * FROM tb_burden_estimates
WHERE year = 2024 AND incident_cases >=10000
ORDER BY incidence_per_100k DESC
LIMIT 20;

-- WHO high-burden method applied to 2024 estimates, using WHO 20 +10 method on 2024 data.
CREATE TABLE high_burden_30 AS 
SELECT country, iso3, incident_cases, incidence_per_100k, 'Top 20 by cases' AS burden_class
FROM (SELECT * FROM tb_burden_estimates WHERE year = 2024
		ORDER BY incident_cases DESC, country
		LIMIT 20) t
UNION ALL
SELECT country, iso3, incident_cases, incidence_per_100k, 'Top 10 by rate' AS burden_class
FROM (SELECT * FROM tb_burden_estimates
		WHERE year = 2024 AND incident_cases >=10000
		AND iso3 NOT IN ( SELECT iso3 FROM
					(SELECT iso3 FROM tb_burden_estimates
						WHERE year = 2024
						ORDER BY incident_cases DESC, country
						LIMIT 20) p)
                        ORDER BY incidence_per_100k DESC, country
                        LIMIT 10) r;
SELECT * FROM high_burden_30;
SELECT * FROM high_burden_30 WHERE iso3 IN ('COG','COD');

-- 2. Compare Nigeria to other high burden countries
-- by cases detected
SELECT hbc.country, hbc.incidence_per_100k, deaths_per_100k, case_detection_pct
FROM high_burden_30 hbc
JOIN tb_burden_estimates tb
	ON hbc.iso3 = tb.iso3
WHERE year = 2024
ORDER BY case_detection_pct DESC;
-- by incidence rate
SELECT hbc.country, hbc.incidence_per_100k, deaths_per_100k, case_detection_pct
FROM high_burden_30 hbc
JOIN tb_burden_estimates tb
	ON hbc.iso3 = tb.iso3
WHERE year = 2024
ORDER BY hbc.incidence_per_100k DESC;

-- by estimated % of new cases that are drug-resistant.
SELECT hbc.country, m.rr_pct_new, m.rr_pct_retreated, m.rr_cases_est
FROM high_burden_30 hbc
JOIN mdr_rr_burden_estimates m
	ON hbc.iso3 = m.iso3
WHERE year = '2024'
ORDER BY m.rr_pct_new DESC;
-- total cases for both new and previously treated patients that are drug-resistant
SELECT hbc.country, m.rr_pct_new, m.rr_pct_retreated, m.rr_cases_est
FROM high_burden_30 hbc
JOIN mdr_rr_burden_estimates m
	ON hbc.iso3 = m.iso3
WHERE year = 2024
ORDER BY m.rr_cases_est DESC;

-- by % of cohort(new and relapse cases) who were succesfully treated in 2023
SELECT hbc.country, new_cohort, new_success, new_succ_rate_pct, mdr_cohort, mdr_success,
		(mdr_success/mdr_cohort * 100) AS mdr_succ_rate_pct
FROM high_burden_30 hbc
JOIN treatment_outcomes t
	ON hbc.iso3 = t.iso3
WHERE year = 2023
ORDER BY new_succ_rate_pct DESC;
-- by % of cohort( MDR-tb cases) who were succesfully treated in 2022.
SELECT hbc.country, new_cohort, new_success, new_succ_rate_pct, mdr_cohort, mdr_success,
		ROUND(mdr_success/mdr_cohort * 100, 1) AS mdr_succ_rate_pct
FROM high_burden_30 hbc
JOIN treatment_outcomes t
	ON hbc.iso3 = t.iso3
WHERE year = 2022
ORDER BY mdr_succ_rate_pct DESC;
-- % of resistant cases reached (who started treatment) out of the total resistant cases
SELECT hbc.country, t.mdr_cohort, m.rr_cases_est, 
	ROUND(t.mdr_cohort/m.rr_cases_est * 100, 1) AS pct_reached
FROM high_burden_30 hbc
JOIN treatment_outcomes t
	ON hbc.iso3 = t.iso3
JOIN mdr_rr_burden_estimates m
	ON hbc.iso3 = m.iso3
    AND m.year = t.year
WHERE t.year = 2022
ORDER BY pct_reached DESC;

-- summary report
CREATE VIEW country_summary AS
SELECT
	h.country, h.iso3,
	b.incidence_per_100k, 
	b.deaths_per_100k, 
    b.case_detection_pct, 
    m.rr_pct_new, 
    m.rr_cases_est,
    o23.new_succ_rate_pct AS success_23,
    ROUND(o23.new_success/o23.new_cohort * 100, 1) AS success_2023,
    ROUND(o22.mdr_success/o22.mdr_cohort *100, 1) AS mdr_success_2022,
    ROUND(o22.mdr_cohort/m22.rr_cases_est *100, 1) AS pct_reached_2022
FROM high_burden_30 h 
LEFT JOIN tb_burden_estimates b ON b.iso3 = h.iso3 AND b.year = 2024
LEFT JOIN mdr_rr_burden_estimates m ON m.iso3 = h.iso3 AND m.year = 2024
LEFT JOIN treatment_outcomes o23 ON o23.iso3 = h.iso3 AND o23.year = 2023
LEFT JOIN treatment_outcomes o22 ON o22.iso3 = h.iso3 AND o22.year = 2022
LEFT JOIN mdr_rr_burden_estimates m22 ON m22.iso3 = h.iso3 AND m22.year = 2022;

SELECT * FROM (
	SELECT country,
		RANK() OVER(ORDER BY case_detection_pct DESC) AS rank_detection,
		RANK() OVER(ORDER BY success_2023 DESC) AS rank_success,
		RANK() OVER(ORDER BY mdr_success_2022 DESC) AS rank_mdr_success,
		RANK() OVER(ORDER BY pct_reached_2022 DESC) AS rank_reach,
		RANK() OVER(ORDER BY rr_pct_new DESC) AS rank_rr_pct
	FROM country_summary)t
WHERE country = 'Nigeria';

-- trend over time
SELECT year, 
		case_detection_pct, 
        LAG(case_detection_pct) OVER (ORDER BY year) AS previous_detection_pct,
        case_detection_pct - LAG(case_detection_pct) OVER (ORDER BY year) AS pct_detection_change
FROM tb_burden_estimates
WHERE iso3 = 'NGA' AND year >= 2015
ORDER BY year;

SELECT year, 
		deaths_per_100k, 
        LAG(deaths_per_100k) OVER (ORDER BY year) AS previous_death_cases_per_100k,
        deaths_per_100k - LAG(deaths_per_100k) OVER (ORDER BY year) AS deaths_change
FROM tb_burden_estimates
WHERE iso3 = 'NGA' AND year >= 2015
ORDER BY year;

SELECT year, 
		incident_cases, 
        LAG(incident_cases) OVER (ORDER BY year) AS last_year_new_cases,
        incident_cases - LAG(incident_cases) OVER (ORDER BY year) AS incidence_change
FROM tb_burden_estimates
WHERE iso3 = 'NGA' AND year >= 2015
ORDER BY year;