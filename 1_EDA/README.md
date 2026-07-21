# SQL Exploratory Data Analysis
## United States and Costa Rica Job Market Analysis
### Data Engineering

This is a SQL project analyzing the data engineer job market in the United States and in Costa Rica, using real world job posting data. **It demonstrates my ability to write production-quality analytical SQL, design effective queries, and think outside of the box to solve real-business problems.**

## Executive Summary

- **Project Scope:** Built a **4-part SQL analysis pipeline** — a statistical EDA pass followed by three analytical scripts — answering key questions about the data engineer job market in the United States and Costa Rica.
- **Data Modeling:** Used **multi-table joins** across the `job_postings_fact`, `skills_job_dim`, `skills_dim`, and `company_dim` fact/dimension tables to extract insights and deliver actionable next steps.
- **Analytics:** Applied **aggregation, filtering, sorting, window functions, and percentile/IQR-based outlier detection** to profile the data and find top skills by demand, salary, and overall value.
- **Outcomes:** Delivered **actionable** insights on SQL/Python/AWS dominance, cloud trends, salary compression in smaller markets, and which skills reward learning effort most.

## Problem & Context

Data Engineer job postings look different depending on the market — the US is a large, mature tech hub, while Costa Rica is a smaller, emerging one. Before comparing them on demand or pay, it's worth first confirming the data itself is trustworthy: complete, free of major gaps, and not distorted by extreme outliers. This project answers that in stages:

| File | Business Question |
|---|---|
| [00_EDA.sql](00_EDA.sql) | Is the data complete, and what does its distribution look like? |
| [01_Top_Demanded_Skills.sql](01_Top_Demanded_Skills.sql) | What are the top 10 most in-demand Data Engineer skills in each country? |
| [02_Top_Paying_Skills.sql](02_Top_Paying_Skills.sql) | Which skills pay the most (by median salary) in each country? |
| [03_Most_Optimal_Skills.sql](03_Most_Optimal_Skills.sql) | Which skills balance high demand *and* high pay — the most "optimal" to learn? |

All analysis is scoped to `job_title_short = 'Data Engineer'` unless a query is explicitly comparing across all titles.

## Tech Stack

- **Query Engine —** DuckDB for last OLAP-style analytical queries.
- **SQL** — CTEs, window functions (`OVER`), the `FILTER` clause, ordered-set aggregates (`MEDIAN`, `PERCENTILE_CONT`), and math functions (`LN`) for demand-weighted scoring
- **Git & GitHub** — version control for tracking the analysis over time
- **VS Code** — writing and running queries

## Analysis Overview

### 0. Statistical EDA ([00_EDA.sql](00_EDA.sql))

Before ranking anything by demand or pay, this file profiles the raw data across four angles:

- **Data profiling** — row counts across all four tables, null rates on `salary_year_avg`, `salary_hour_avg`, `company_id`, `job_country`, and `job_posted_date`, and the date range the postings cover.
- **Salary distribution** — a five-number summary (min, Q1, median, Q3, max) plus mean and standard deviation for `salary_year_avg`, followed by an IQR-based query (`Q1 - 1.5*IQR` to `Q3 + 1.5*IQR`) that surfaces individual postings flagged as statistical outliers.
- **Categorical distributions** — posting counts by job title (all titles), then for Data Engineer specifically: by country, remote vs. on-site (with median salary per arrangement), and schedule type.
- **Skills-per-posting** — the distribution of how many skills are tagged per posting, including the share of postings with zero skills listed.

This step exists to catch what would otherwise silently skew later rankings: heavy nulls in salary fields, a handful of extreme salary outliers, or postings with no skills tagged at all.

### 1. Top Demanded Skills ([01_Top_Demanded_Skills.sql](01_Top_Demanded_Skills.sql))

Ranks the top 10 skills by posting count for Data Engineer roles, run separately for the US and Costa Rica, with each skill's share of its own top-10 group shown as a percentage.

| Rank | United States | Demand | % of Top 10 | Costa Rica | Demand | % of Top 10 |
|---|---|---|---|---|---|---|
| 1 | SQL | 56,933 | 19.75% | SQL | 852 | 18.93% |
| 2 | Python | 55,159 | 19.14% | Python | 819 | 18.20% |
| 3 | AWS | 35,698 | 12.39% | AWS | 604 | 13.42% |
| 4 | Azure | 29,236 | 10.14% | Azure | 493 | 10.96% |
| 5 | Spark | 26,768 | 9.29% | Spark | 478 | 10.62% |
| 6 | Snowflake | 19,996 | 6.94% | Snowflake | 290 | 6.44% |
| 7 | Java | 19,405 | 6.73% | Java | 254 | 5.64% |
| 8 | Databricks | 15,430 | 5.35% | Scala | 244 | 5.42% |
| 9 | Scala | 14,921 | 5.18% | GCP | 240 | 5.33% |
| 10 | Kafka | 14,688 | 5.10% | Tableau | 226 | 5.02% |

**Insight:** the top 7 skills are nearly identical between markets (SQL, Python, AWS, Azure, Spark, Snowflake, Java) — the foundational skill set for Data Engineering doesn't change much by geography, only the absolute scale of demand does (US postings run 20–60x higher than Costa Rica's).

### 2. Top Paying Skills ([02_Top_Paying_Skills.sql](02_Top_Paying_Skills.sql))

Ranks skills by **median** salary (chosen over mean to resist outlier skew) for Data Engineer roles, filtered to skills with at least 100 postings so pay figures aren't driven by a handful of listings.

**Key Insights:**

- **The US pays substantially more at the top.** The highest-paying US skill (Mongo, $207K) sits well above Costa Rica's top skill (R, ~$164K) — CR's #1 is roughly equivalent to a mid-tier US skill, landing between the US #4 and #10 by salary.
- **Market size is a different order of magnitude.** US postings run into the thousands and tens of thousands (Kafka ~14,700, Airflow ~11,300), while CR's most-demanded skill (SQL) tops out around 850 — the US is a far deeper, more liquid market.
- **CR salaries are heavily compressed; the US spreads out.** Nine CR skills tie at exactly $147,500 — median salary barely differentiates them — while the US top 10 ranges from $155K to $207K, rewarding specific skills more distinctly.
- **The high-paying skills differ in character.** CR's best-paying skills are foundational and cloud-oriented (R, SQL, Python, AWS, Azure, GCP); the US premium goes to more specialized or niche tooling (Mongo, Rust, Golang, Ansible, Puppet, TypeScript).
- **Kafka is the notable common thread** — a top-payer in both markets (~$151K CR, $150K US), but in the US it also carries the highest demand of any skill, whereas in CR it's a relatively niche 202 postings.

### 3. Most Optimal Skills ([03_Most_Optimal_Skills.sql](03_Most_Optimal_Skills.sql))

Combines demand and pay into a single **optimal score** for United States Data Engineer postings: `(median_salary × ln(demand_count)) / 1,000,000`. The natural log dampens raw demand count so a skill with extreme posting volume (like Kafka) doesn't automatically dominate a skill with strong-but-moderate demand — pay and demand end up weighted more evenly.

| Skill | Median Salary | ln(Demand) | Optimal Score |
|---|---|---|---|
| Python | $135,000 | 8.56 | 1.16 |
| SQL | $129,999.80 | 8.58 | 1.12 |
| AWS | $137,500 | 8.10 | 1.11 |
| Mongo | $207,000 | 5.31 | 1.10 |
| Kafka | $150,000 | 7.31 | 1.10 |
| Spark | $140,000 | 7.84 | 1.10 |
| Airflow | $147,500 | 7.06 | 1.04 |

**Key Insights:**

- **The most valuable skills are the everyday ones.** Python, SQL, and AWS come out on top because they're needed almost everywhere and still pay well — not the flashiest, but they open the most doors and are the best all-around bets for landing and growing in a role.
- **The biggest paycheck isn't always the best move.** MongoDB pays the most, but very few jobs ask for it — a high salary doesn't help much if there's barely any demand, so a niche high-payer is riskier than it looks.
- **You don't have to overthink which skill to pick.** The top skills are all clustered close together in value, so there's no single "right" answer — pick based on what interests you or what you already know, and you won't be leaving much on the table.

*Note: this script scores the United States only. Costa Rica is excluded here by design, not oversight — CR job postings have sparse `salary_year_avg` coverage (confirmed by the null-rate checks in [00_EDA.sql](00_EDA.sql)), so a demand-weighted optimal score built on median salary would be unreliable for that market at this sample size.*

## SQL Skills Demonstrated

- **CTEs** (`WITH`) to stage intermediate results — top-N skill sets, IQR bound calculations, per-job skill counts
- **Window functions** (`SUM(...) OVER ()`) to compute share-of-total percentages without a self-join
- **Joins** — `INNER JOIN` across fact/dimension tables to attach skills to postings, `LEFT JOIN` to preserve postings with zero skills tagged, `CROSS JOIN` to broadcast single-row aggregate bounds across every posting
- **Aggregate functions** — `COUNT`, `AVG`, `MIN`/`MAX`, `MEDIAN`, `STDDEV`, and ordered-set aggregates (`PERCENTILE_CONT ... WITHIN GROUP`) for full distributional summaries
- **Conditional aggregation** with `FILTER (WHERE ...)` for null-rate and outlier-share calculations
- **`HAVING`** to filter grouped results by demand threshold, avoiding low-sample noise in salary rankings
- **IQR-based outlier detection** (`Q1 - 1.5*IQR` / `Q3 + 1.5*IQR`) applied as a reusable pattern via CTEs
- **`LN()`-damped scoring** to combine two metrics (salary and demand) on more comparable scales
- **`UNION ALL`** to stack single-row profiling summaries into one result set
- **`CASE WHEN`** for deriving categorical labels (e.g. Remote vs. On-site) from boolean columns
