SELECT
    job_id, 
    job_title_short
FROM
    job_postings_fact jpf
LEFT JOIN company_dim cd 
    ON jpf.company_id = cd.company_id;


SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    cd.company_id, 
    jpf.job_location
FROM
    job_postings_fact jpf
INNER JOIN company_dim cd
    ON jpf.company_id = cd.company_id
LIMIT 10;


-- Skills JOINs

-- Data Overview
SELECT *
FROM skills_job_dim
LIMIT 10;

-- FACT Table

SELECT job_id, Skills
FROM job_postings_fact
LIMIT 10;

-- LEFT JOIN

SELECT  jpf.job_id, 
        jpf.job_title_short, 
        sjd.skill_id,
        sd.skills


FROM job_postings_fact jpf 
LEFT JOIN skills_job_dim sjd 
        ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd 
        ON sjd.skill_id = sd.skill_id; 


-- INNER JOIN

SELECT  jpf.job_id, 
        jpf.job_title_short, 
        sjd.skill_id,
        sd.skills


FROM job_postings_fact jpf 
INNER JOIN skills_job_dim sjd 
        ON jpf.job_id = sjd.job_id
INNER JOIN skills_dim sd 
        ON sjd.skill_id = sd.skill_id; 

