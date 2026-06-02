--https://platform.stratascratch.com/coding/10566-search-click-success-rate-by-user-segment?code_type=1
WITH max_date AS (
    SELECT DATE(MAX(event_timestamp)) AS latest_date
    FROM search_events
),
user_segments AS (
    SELECT a.user_id,
        CASE
            WHEN a.registration_date >= m.latest_date - INTERVAL '30 days' THEN 'new'
            ELSE 'existing'
        END AS user_segment
    FROM accounts a
        CROSS JOIN max_date m
),
searches AS (
    SELECT se.event_id,
        se.user_id,
        se.session_id,
        se.event_timestamp AS search_time
    FROM search_events se
    WHERE se.event_type = 'search'
),
search_results AS (
    SELECT s.event_id,
        s.user_id,
        CASE
            WHEN fc.click_time IS NOT NULL
            AND fc.click_time <= s.search_time + INTERVAL '30 seconds' THEN 1
            ELSE 0
        END AS successful_search
    FROM searches s
        LEFT JOIN LATERAL (
            SELECT MIN(c.event_timestamp) AS click_time
            FROM search_events c
            WHERE c.user_id = s.user_id
                AND c.session_id = s.session_id
                AND c.event_type = 'click'
                AND c.event_timestamp > s.search_time
        ) fc ON TRUE
)
SELECT us.user_segment,
    COUNT(*) AS total_searches,
    SUM(sr.successful_search) AS successful_searches,
    ROUND(
        SUM(sr.successful_search)::NUMERIC / COUNT(*),
        4
    ) AS success_rate
FROM search_results sr
    JOIN user_segments us ON sr.user_id = us.user_id
GROUP BY us.user_segment
ORDER BY us.user_segment;