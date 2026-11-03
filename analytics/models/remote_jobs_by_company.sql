-- Remote jobs by company.sql: total job posts + remote share of company posts
WITH total_posts AS (
    SELECT company_name,
        COUNT(*) AS total_postings,
        COUNT(DISTINCT job_title) AS unique_job_title
    FROM {{ ref('job_postings') }}
    GROUP BY company_name
),
remote_jobs AS (
    SELECT company_name,
    COUNT(*) AS remote_posts
    FROM {{ ref('job_postings') }}
    WHERE job_work_from_home
    GROUP BY company_name
)
SELECT company_name, unique_job_title, total_postings, COALESCE(remote_posts, 0) AS remote_posts,
        ROUND( 100.0 * COALESCE(remote_posts, 0) / NULLIF(total_postings, 0), 1) AS pct_remote_posts
FROM total_posts
LEFT JOIN remote_jobs USING(company_name)
ORDER BY pct_remote_posts DESC

