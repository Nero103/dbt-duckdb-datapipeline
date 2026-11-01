-- models/monthly_summary.sql: monthly totals + remote share from two refs
WITH totals AS (
    SELECT month, SUM(postings) AS total_postings
    FROM {{ ref('jobs_per_month') }}
    GROUP BY month
),
remote AS (
    SELECT DATE_TRUNC('month', search_date) AS month, COUNT(*) AS remote_postings
    FROM {{ ref('job_postings') }}
    WHERE job_work_from_home
    GROUP BY month
)
SELECT month, total_postings, COALESCE(remote_postings, 0) AS remote_postings,
       ROUND(100.0 * COALESCE(remote_postings, 0) / NULLIF(total_postings, 0), 1) AS pct_remote
FROM totals
LEFT JOIN remote USING (month)
ORDER BY month
