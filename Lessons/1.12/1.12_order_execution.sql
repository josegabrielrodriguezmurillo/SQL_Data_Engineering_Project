/* 
Find the top 10 companies for posting jobs. 
They must have >3000 postings
Limit to only US jobs. 
*/
 
SELECT
    cd.name,   
    COUNT(jpf.*) AS posting_count

FROM job_postings_fact jpf
LEFT JOIN company_dim cd
    ON jpf.company_id = cd.company_id

WHERE jpf.job_country = 'United States'

GROUP BY cd.name

HAVING posting_count > 3000

ORDER BY posting_count DESC

LIMIT 10;

