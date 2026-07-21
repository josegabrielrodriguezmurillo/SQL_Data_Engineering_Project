/*
Business Problem:
 - What are the highest-paying skills for Data Engineers
 in Costa Rica vs United States? 

IMPORTANT CONSIDERATIONS: 

- Use median salary to determine highest-paying skills. 
- Skill frequency is used to show what skills command the
highest compensation while showing how common those skills are. 
*/

-- USA Skills with Higher Pay

SELECT
        sd.skills,
        COUNT(jpf.*) AS demand_count,
        ROUND(MEDIAN(jpf.salary_year_avg),1) AS median_salary

    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd -- Inner joing to discard jobs without skills attach to it.
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id

    WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'United States'

    GROUP BY sd.skills

    HAVING demand_count >= 100

    ORDER BY median_salary DESC

    LIMIT 25;


-- Costa Rica Skills with Higher Pay

SELECT
        sd.skills,
        COUNT(jpf.*) AS demand_count,
        ROUND(MEDIAN(jpf.salary_year_avg),1) AS median_salary

    FROM job_postings_fact jpf
    INNER JOIN skills_job_dim sjd -- Inner joing to discard jobs without skills attach to it.
        ON jpf.job_id = sjd.job_id
    INNER JOIN skills_dim sd
        ON sjd.skill_id = sd.skill_id

    WHERE jpf.job_title_short = 'Data Engineer'
    AND jpf.job_country = 'Costa Rica'

    GROUP BY sd.skills

    HAVING demand_count >= 100 AND median_salary IS NOT NULL

    ORDER BY median_salary DESC

    LIMIT 25;


/*
KEY INSIGHTS: 

- The US pays substantially more at the top. 
    The highest-paying US skill (Mongo, $207k) sits well above Costa Rica's top skill (R, ~$164k). 
    In fact CR's #1 is roughly equivalent to a mid-tier US skill — it lands between the US #4 and #10 by salary.
- Market size is a different order of magnitude. 
    US postings run into the thousands and tens of thousands (Kafka ~14,700, Airflow ~11,300), while CR's most-demanded skill (SQL) tops out around 850. 
    The US is a far deeper, more liquid market.
    CR salaries are heavily compressed; the US spreads out. Nine CR skills are tied at exactly $147,500 — median salary barely differentiates them. 
    The US top 10 ranges from $155k to $207k, so the market rewards specific skills more distinctly.
- The high-paying skills differ in character. 
    CR's best-paying skills are foundational and cloud-oriented (R, SQL, Python, AWS, Azure, GCP). 
    The US premium goes to more specialized or niche tooling and languages (Mongo, Rust, Golang, Ansible, Puppet, TypeScript).
- Kafka is the notable common thread.
     It's a top-payer in both markets (~$151k in CR, $150k in US) — but in the US it also carries the highest demand of any skill, whereas in CR it's a relatively niche 202 postings.

United States
┌────────────┬──────────────┬───────────────┐
│   skills   │ demand_count │ median_salary │
│  varchar   │    int64     │    double     │
├────────────┼──────────────┼───────────────┤
│ mongo      │         2097 │      207000.0 │
│ rust       │          282 │      175000.0 │
│ atlassian  │          506 │      165000.0 │
│ golang     │          537 │      158500.0 │
│ groovy     │          173 │      157500.0 │
│ ansible    │         1169 │      157500.0 │
│ puppet     │          260 │      157500.0 │
│ typescript │          565 │      155000.0 │
│ plotly     │          149 │      155000.0 │
│ zoom       │          215 │      155000.0 │
│ ruby       │         1298 │      150000.0 │
│ kafka      │        14688 │      150000.0 │
│ cassandra  │         4296 │      150000.0 │
│ node       │          388 │      150000.0 │
│ kubernetes │         6384 │      150000.0 │
│ redis      │          735 │      150000.0 │
│ pytorch    │          982 │      150000.0 │
│ airflow    │        11337 │      147500.0 │
│ graphql    │          665 │      146500.0 │
│ c          │         1578 │      146325.0 │
│ centos     │          154 │      145500.0 │
│ terraform  │         4955 │      145000.0 │
│ fastapi    │          295 │      145000.0 │
│ vmware     │          241 │      143798.3 │
│ slack      │          203 │      142500.0 │
└────────────┴──────────────┴───────────────┘

Costa Rica

┌────────────┬──────────────┬───────────────┐
│   skills   │ demand_count │ median_salary │
│  varchar   │    int64     │    double     │
├────────────┼──────────────┼───────────────┤
│ r          │          113 │      163782.0 │
│ kafka      │          202 │      151250.0 │
│ java       │          254 │      150500.0 │
│ sql server │          112 │      147500.0 │
│ excel      │          128 │      147500.0 │
│ oracle     │          135 │      147500.0 │
│ hadoop     │          216 │      147500.0 │
│ aws        │          604 │      147500.0 │
│ sql        │          852 │      147500.0 │
│ python     │          819 │      147500.0 │
│ gcp        │          240 │      147500.0 │
│ azure      │          493 │      147500.0 │
│ spark      │          478 │      146750.0 │
│ nosql      │          132 │      146000.0 │
│ snowflake  │          290 │      140870.5 │
│ linux      │          128 │      140870.5 │
│ airflow    │          205 │      140870.5 │
│ databricks │          221 │      136062.5 │
│ docker     │          102 │      134241.0 │
│ kubernetes │          100 │      134241.0 │
│ scala      │          244 │      127891.5 │
│ power bi   │          163 │       98283.0 │
└────────────┴──────────────┴───────────────┘
