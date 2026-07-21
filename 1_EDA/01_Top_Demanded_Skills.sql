/* 
Business Problem: 
 - How do the most in-demand skills for Data Engineers differ between the
   United States and Costa Rica?

Business Questions: 
1. What are the top 10 skills in-demand for data engineers in each country,
    and what share of that country's top 10 does each skill represent?

*/ 

-- TOP 10 Skills for United States Data Engineers job postings

WITH top_skills AS (
    SELECT
        sd.skills,
        COUNT(jpf.*) AS demand_count

    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd -- Inner joing to discard jobs without skills attach to it.
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id

    WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'United States'

    GROUP BY sd.skills

    ORDER BY demand_count DESC

    LIMIT 10
)

SELECT
    skills,
    demand_count,
    ROUND(
        100.0 * demand_count / SUM(demand_count) OVER (), 2
    ) AS pct_of_top10

FROM top_skills

ORDER BY demand_count DESC;

-- TOP 10 Skills for Costa Rica Data Engineers job postings
WITH top_skills_CR AS (
    SELECT
        sd.skills,
        COUNT(jpf.*) AS demand_count

    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd -- Inner joing to discard jobs without skills attach to it.
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id

    WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'Costa Rica'

    GROUP BY sd.skills

    ORDER BY demand_count DESC

    LIMIT 10
)

SELECT
    skills,
    demand_count,
    ROUND(
        100.0 * demand_count / SUM(demand_count) OVER (), 2
    ) AS pct_of_top10

FROM top_skills_CR

ORDER BY demand_count DESC;

-- Comparing US vs CR job postings for Data Engineers.

/*

United States
┌────────────┬──────────────┬──────────────┐
│   skills   │ demand_count │ pct_of_top10 │
│  varchar   │    int64     │    double    │
├────────────┼──────────────┼──────────────┤
│ sql        │        56933 │        19.75 │
│ python     │        55159 │        19.14 │
│ aws        │        35698 │        12.39 │
│ azure      │        29236 │        10.14 │
│ spark      │        26768 │         9.29 │
│ snowflake  │        19996 │         6.94 │
│ java       │        19405 │         6.73 │
│ databricks │        15430 │         5.35 │
│ scala      │        14921 │         5.18 │
│ kafka      │        14688 │          5.1 │
└────────────┴──────────────┴──────────────┘

Costa Rica
┌───────────┬──────────────┬──────────────┐
│  skills   │ demand_count │ pct_of_top10 │
│  varchar  │    int64     │    double    │
├───────────┼──────────────┼──────────────┤
│ sql       │          852 │        18.93 │
│ python    │          819 │         18.2 │
│ aws       │          604 │        13.42 │
│ azure     │          493 │        10.96 │
│ spark     │          478 │        10.62 │
│ snowflake │          290 │         6.44 │
│ java      │          254 │         5.64 │
│ scala     │          244 │         5.42 │
│ gcp       │          240 │         5.33 │
│ tableau   │          226 │         5.02 │
└───────────┴──────────────┴──────────────┘
*/

