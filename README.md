# Nigeria's TB Burden Compared with other High-Burden Countries.

## Description 
Is Nigeria finding and curing its tuberculosis (TB) patients, including those with drug-resistant TB? This project compares Nigeria with 29 other high-burden countries using WHO data (estimates up to 2024). Using WHO Global TB Programme data from the Global Tuberculosis Report 2025, with 2024 estimates, the project explores estimated TB cases, incidence, deaths, case detection, treatment outcomes, and rifampicin-resistant/multidrug-resistant TB.

## Purpose
This analysis shows where Nigeria stands on tuberculosis (TB) compared with other high-burden countries. It looks at whether Nigeria is finding patients (case detection), curing them (treatment outcomes), and reaching those with drug-resistant TB (MDR-TB). The goal is to find where the biggest gap is.

## Country-selection note
The 30 high-burden country comparison group was independently constructed by applying an adaptation of the WHO method to 2024 estimates: the 20 countries with the highest estimated new TB cases, plus 10 additional countries with the highest incidence rates among countries with at least 10,000 estimated cases. This is not the WHO's official high-burden-country list, which uses a different reference period.

## Questions answered
- How big is the problem? Nigeria's TB cases, incidence rate and deaths compared with other high-burden countries, and the trend over time.
- Are we finding the patients? The case detection rate (cases found compared with estimated cases).
- Are we curing them? Treatment success for new TB cases and for MDR-TB.
- How serious is drug resistance? The share of new cases that are rifampicin-resistant, and how many resistant cases are estimated and reached.

## Tools Used
- Excel Power Query for Cleaning and renaming columns.
- MySQL for Analysis
- PowerBI for Visualization

## Data Source
Data were downloaded on 16 October 2026 from the WHO Global Tuberculosis Programme data page. The source was the WHO Global TB Report 2025, with estimates through 2024.

Files used:
- TB_burden_countries_2026-10-16.csv — estimated cases, deaths, incidence, and case detection
- TB_outcomes_2026-10-16.csv — treatment outcomes
- MDR_RR_TB_burden_estimates_2026-10-16.csv — drug-resistant TB estimates
- TB_data_dictionary_2026-10-16.csv — source-column definitions.
The tables were linked using country code (iso3) and year.

## Data Preparation
- Imported the source tables and renamed columns for consistency.
- Converted blank values to NULL so missing data would be retained rather than dropped during numeric import.
- Converted fields to appropriate numeric types.
- Checked imported row counts against the source files.
- Validated that Nigeria had 25 annual records for 2000–2024 in the TB burden table.
- Documented missing estimates and data limitations in the project documentation.
Detailed cleaning steps are documented in the separate Data Cleaning Documentation.

## Methodology
1. Selected 30 countries using the criteria described above, based on 2024 estimates.
2. Compared Nigeria with six other countries among the selected group with the highest estimated case counts: India, Indonesia, China, the Philippines, Pakistan, and the Democratic Republic of the Congo.
3. Used the latest available year for each indicator:
   - Burden, incidence, deaths, case detection, and resistance estimates: 2024
   - Treatment success for new and relapse cases: 2023 cohort
   - MDR-TB treatment success and resistant cases starting treatment: 2022
4. Ranked rates using unrounded values calculated from raw counts where applicable, to reduce ties caused by rounded percentages.
5. Treated the share of resistant cases reached as an approximate indicator because MDR-TB and rifampicin-resistant TB (RR-TB) are related but not identical groups.

## Key Findings
- Nigeria ranked 6th of the 30 selected countries by estimated new TB cases, with approximately 510,000 cases in 2024.
-Nigeria's estimated case-detection rate increased from 21% in 2015 to 79% in 2024.
- Approximately 107,000 estimated cases were not detected in 2024.
- Treatment success for new and relapse TB cases was 94% for the 2023 cohort.
- The MDR-TB treatment-success rate was 76.3% for the 2022 cohort.
- Nigeria's estimated incidence rate was 219 per 100,000 in 2024. The source data hold this rate constant across the years analysed, so the increase in estimated case counts should not be interpreted as an increase in the incidence rate.
- An estimated 8,200 rifampicin-resistant TB cases were reported for Nigeria in 2024 in the source data.
- In 2022, 3,185 patients started MDR-TB treatment compared with an estimated 10,000 resistant cases. This is an approximate comparison of related, but non-identical, groups.
These are descriptive findings from modelled estimates; they do not establish that changes in one indicator caused changes in another.

## Power BI Dashboard
The dashboard contains four pages:
1. Global Overview — Nigeria's position, country comparisons, and trends over time.
2. Selected High-Burden Countries — the 30-country comparison group and selection criteria.
3. Nigeria vs other top 7 — case detection, treatment success, and drug-resistance indicators.
4. Key Insights — a summary of the main findings.

### Global Overview
![Global TB burden](global-tb-burden.png)

### High-Burden Countries
![High-Burden Countries](high-burden-countries.png)

### Nigeria vs Peers
![Nigeria vs Peers](nigeria-vs-peers.png)

### Insights 
![Insights for TB burden analysis](insights-for-tb-burden-analysis.png)


## Limitations
- The country group is a project-defined comparison group, not the WHO's official list.
- WHO estimates are model-based and may be revised in later releases.
-Some countries have missing drug-resistance estimates.
- MDR-TB outcome data were available through 2022 in the dataset used.
- The estimated share of resistant cases reached is approximate because the MDR-TB treatment cohort and estimated RR-TB burden are not identical populations.
- Nigeria's incidence rate is held constant in the source data across the years analysed, limiting trend interpretation for that indicator.

## Recommendations
Note that these are analytical focus areas, not clinical or policy recommendations.
- Investigate ways to reduce the gap between estimated and detected TB cases.
- Explore access to drug-susceptibility testing and treatment for drug-resistant TB.
- Examine factors associated with MDR-TB treatment outcomes.
- Track changes as new WHO estimates become available.


## References
World Health Organization. Global Tuberculosis Programme data / Global Tuberculosis Report 2025. Data downloaded 16 October 2026.
https://www.who.int/teams/global-tuberculosis-programme/data
