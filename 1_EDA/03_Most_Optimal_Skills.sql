/*
Business Problem:
 - What are the most optimal skills for data engineers, 
 taking into consideration demand and salary. 
 What are some differences in the job market between CR
 and the USA? 

IMPORTANT CONSIDERATIONS: 
- Create a ranking column that combines demand count
    and median salary to identify most valuable skills.
- This approach highlights skills that balance market
demand and financial reward. 

*/

-- USA Most Valuable Skills for Data Engineers

SELECT
        sd.skills,
        ROUND(MEDIAN(jpf.salary_year_avg),1) AS median_salary, 
        ROUND(LN(COUNT(jpf.*)),2) AS ln_demand_count,
        ROUND((MEDIAN(jpf.salary_year_avg) * LN(COUNT(jpf.*)))/1_000_000,2) AS optimal_score

    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd -- Inner joing to discard jobs without skills attach to it.
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id

    WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'United States'
    AND jpf.salary_year_avg IS NOT NULL

    GROUP BY sd.skills

    ORDER BY optimal_score DESC

    LIMIT 25;

/*

┌────────────┬───────────────┬─────────────────┬───────────────┐
│   skills   │ median_salary │ ln_demand_count │ optimal_score │
│  varchar   │    double     │     double      │    double     │
├────────────┼───────────────┼─────────────────┼───────────────┤
│ python     │      135000.0 │            8.56 │          1.16 │
│ sql        │      129999.8 │            8.58 │          1.12 │
│ aws        │      137500.0 │             8.1 │          1.11 │
│ mongo      │      207000.0 │            5.31 │           1.1 │
│ kafka      │      150000.0 │            7.31 │           1.1 │
│ spark      │      140000.0 │            7.84 │           1.1 │
│ airflow    │      147500.0 │            7.06 │          1.04 │
│ snowflake  │      136000.0 │            7.57 │          1.03 │
│ java       │      138100.0 │            7.49 │          1.03 │
│ azure      │      130000.0 │            7.91 │          1.03 │
│ hadoop     │      140000.0 │            7.26 │          1.02 │
│ scala      │      140500.0 │             7.3 │          1.02 │
│ redshift   │      138100.0 │            7.21 │           1.0 │
│ nosql      │      137500.0 │             7.1 │          0.98 │
│ kubernetes │      150000.0 │            6.51 │          0.98 │
│ databricks │      133400.0 │            7.23 │          0.96 │
│ cassandra  │      150000.0 │            6.04 │          0.91 │
│ gcp        │      135000.0 │             6.7 │           0.9 │
│ pyspark    │      139000.0 │            6.49 │           0.9 │
│ docker     │      140000.0 │            6.46 │           0.9 │
│ terraform  │      145000.0 │            6.19 │           0.9 │
│ flow       │      135000.0 │            6.63 │          0.89 │
│ mysql      │      137500.0 │             6.5 │          0.89 │
│ oracle     │      128825.0 │             6.8 │          0.88 │
│ tableau    │      124620.0 │            6.97 │          0.87 │
└────────────┴───────────────┴─────────────────┴───────────────┘

KEY INSIGHTS: 
- The most valuable skills are the everyday ones. Python, SQL, and AWS come out on top because they're needed almost everywhere and still pay well. 
    They're not the flashiest, but they open the most doors. 
    The best all-around bets for landing and growing in a role.
- The biggest paycheck isn't always the best move. 
    MongoDB pays the most, but very few jobs ask for it. 
    A high salary doesn't help much if there's barely any demand, so a niche high-payer is riskier than it looks.
- You don't have to overthink which skill to pick. 
    The top skills are all clustered close together in value, so there's no single "right" answer. 
    Pick based on what interests you or what you already know,you won't be leaving much on the table.

*/