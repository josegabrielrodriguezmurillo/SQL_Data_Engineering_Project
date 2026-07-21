/*
Business Problem:
 - Before diving into skill-demand and pay analysis, get a clear read on the
   shape, quality, and distribution of the underlying job posting data.

Business Questions:
1. How complete is the dataset (row counts, null rates, date coverage)?
2. What does the salary distribution look like for Data Engineer roles, and
   which postings are statistical outliers?
3. How are postings distributed by title overall, and by country, work
   arrangement, and schedule type for Data Engineer roles specifically?
4. How many skills are typically tagged per Data Engineer job posting?
*/


-- ============================================================
-- 1. DATA PROFILING
-- ============================================================

-- 1a. Row counts across core tables
SELECT
    'job_postings_fact' AS table_name,
    COUNT(*) AS row_count
FROM job_postings_fact

UNION ALL

SELECT
    'company_dim',
    COUNT(*)
FROM company_dim

UNION ALL

SELECT
    'skills_dim',
    COUNT(*)
FROM skills_dim

UNION ALL

SELECT
    'skills_job_dim',
    COUNT(*)
FROM skills_job_dim;


-- 1b. Null / completeness rate for key columns
SELECT
    COUNT(*) AS total_rows,
    ROUND(100.0 * COUNT(*) FILTER (WHERE salary_year_avg IS NULL) / COUNT(*), 2) AS pct_null_salary_year,
    ROUND(100.0 * COUNT(*) FILTER (WHERE salary_hour_avg IS NULL) / COUNT(*), 2) AS pct_null_salary_hour,
    ROUND(100.0 * COUNT(*) FILTER (WHERE company_id IS NULL) / COUNT(*), 2) AS pct_null_company,
    ROUND(100.0 * COUNT(*) FILTER (WHERE job_country IS NULL) / COUNT(*), 2) AS pct_null_country,
    ROUND(100.0 * COUNT(*) FILTER (WHERE job_posted_date IS NULL) / COUNT(*), 2) AS pct_null_posted_date

FROM job_postings_fact;


-- 1c. Date coverage
SELECT
    MIN(job_posted_date) AS earliest_posting,
    MAX(job_posted_date) AS latest_posting,
    COUNT(DISTINCT DATE_TRUNC('month', job_posted_date)) AS months_covered

FROM job_postings_fact;


-- ============================================================
-- 2. SALARY DISTRIBUTION (Data Engineer roles)
-- ============================================================

-- 2a. Five-number summary + mean/stddev for salary_year_avg
SELECT
    COUNT(*) AS n,
    ROUND(MIN(salary_year_avg), 1) AS min_salary,
    ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_year_avg), 1) AS q1_salary,
    ROUND(MEDIAN(salary_year_avg), 1) AS median_salary,
    ROUND(AVG(salary_year_avg), 1) AS mean_salary,
    ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_year_avg), 1) AS q3_salary,
    ROUND(MAX(salary_year_avg), 1) AS max_salary,
    ROUND(STDDEV(salary_year_avg), 1) AS stddev_salary

FROM job_postings_fact

WHERE job_title_short = 'Data Engineer'
AND salary_year_avg IS NOT NULL;


-- 2b. IQR-based outlier detection
WITH bounds AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY salary_year_avg) AS q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary_year_avg) AS q3

    FROM job_postings_fact

    WHERE job_title_short = 'Data Engineer'
    AND salary_year_avg IS NOT NULL
),

outlier_bounds AS (
    SELECT
        q1,
        q3,
        q3 - q1 AS iqr,
        q1 - 1.5 * (q3 - q1) AS lower_bound,
        q3 + 1.5 * (q3 - q1) AS upper_bound

    FROM bounds
)

SELECT
    jpf.job_id,
    jpf.job_title,
    jpf.job_country,
    jpf.salary_year_avg,
    ob.lower_bound,
    ob.upper_bound

FROM job_postings_fact jpf
CROSS JOIN outlier_bounds ob -- Single-row CTE broadcast to every posting.

WHERE jpf.job_title_short = 'Data Engineer'
AND jpf.salary_year_avg IS NOT NULL
AND (jpf.salary_year_avg < ob.lower_bound OR jpf.salary_year_avg > ob.upper_bound)

ORDER BY jpf.salary_year_avg DESC;


-- ============================================================
-- 3. CATEGORICAL DISTRIBUTIONS
-- ============================================================

-- 3a. Postings by job title (all titles, full dataset)
SELECT
    job_title_short,
    COUNT(*) AS posting_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_total

FROM job_postings_fact

GROUP BY job_title_short

ORDER BY posting_count DESC;


-- 3b. Data Engineer postings by country (top 15)
SELECT
    job_country,
    COUNT(*) AS posting_count

FROM job_postings_fact

WHERE job_title_short = 'Data Engineer'

GROUP BY job_country

ORDER BY posting_count DESC

LIMIT 15;


-- 3c. Remote vs. on-site split, with median salary per arrangement
SELECT
    CASE WHEN job_work_from_home THEN 'Remote' ELSE 'On-site' END AS work_arrangement,
    COUNT(*) AS posting_count,
    ROUND(MEDIAN(salary_year_avg), 1) AS median_salary

FROM job_postings_fact

WHERE job_title_short = 'Data Engineer'

GROUP BY work_arrangement

ORDER BY posting_count DESC;


-- 3d. Schedule type distribution
SELECT
    job_schedule_type,
    COUNT(*) AS posting_count

FROM job_postings_fact

WHERE job_title_short = 'Data Engineer'

GROUP BY job_schedule_type

ORDER BY posting_count DESC;


-- ============================================================
-- 4. SKILLS-PER-POSTING DISTRIBUTION (Data Engineer roles)
-- ============================================================

WITH skills_per_job AS (
    SELECT
        jpf.job_id,
        COUNT(sjd.skill_id) AS skill_count

    FROM job_postings_fact jpf
    LEFT JOIN skills_job_dim sjd -- Left join to keep postings with zero skills tagged.
        ON jpf.job_id = sjd.job_id

    WHERE jpf.job_title_short = 'Data Engineer'

    GROUP BY jpf.job_id
)

SELECT
    MIN(skill_count) AS min_skills,
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY skill_count) AS q1_skills,
    MEDIAN(skill_count) AS median_skills,
    ROUND(AVG(skill_count), 1) AS mean_skills,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY skill_count) AS q3_skills,
    MAX(skill_count) AS max_skills,
    ROUND(100.0 * COUNT(*) FILTER (WHERE skill_count = 0) / COUNT(*), 2) AS pct_no_skills_listed

FROM skills_per_job;


/*
NOTES:
- Run alongside 01_Top_Demanded_Skills.sql and 02_Top_Paying_Skills.sql — the
  completeness and outlier checks here help explain patterns seen there
  (e.g. the repeated $147,500 medians observed in the Costa Rica breakdown).
*/
