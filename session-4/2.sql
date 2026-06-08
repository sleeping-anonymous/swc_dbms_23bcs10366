WITH max_dt AS (
    SELECT MAX(event_timestamp)::date AS latest_date
    FROM search_events
),
user_segments AS (
    SELECT a.user_id,
        CASE
            WHEN a.registration_date >= m.latest_date - INTERVAL '30 days' THEN 'new'
            ELSE 'existing'
        END AS segment
    FROM accounts a
        CROSS JOIN max_dt m
),
searches AS (
    SELECT event_id,
        user_id,
        session_id,
        event_timestamp AS search_time
    FROM search_events
    WHERE event_type = 'search'
),
first_clicks AS (
    SELECT s.event_id,
        MIN(c.event_timestamp) AS first_click_time
    FROM searches s
        LEFT JOIN search_events c ON s.session_id = c.session_id
        AND c.event_type = 'click'
        AND c.event_timestamp >= s.search_time
    GROUP BY s.event_id
)
SELECT us.segment,
    COUNT(*) AS total_searches,
    SUM(
        CASE
            WHEN fc.first_click_time <= s.search_time + INTERVAL '30 seconds' THEN 1
            ELSE 0
        END
    ) AS successful_searches,
    ROUND(
        SUM(
            CASE
                WHEN fc.first_click_time <= s.search_time + INTERVAL '30 seconds' THEN 1
                ELSE 0
            END
        )::numeric / COUNT(*),
        4
    ) AS success_rate
FROM searches s
    JOIN user_segments us ON s.user_id = us.user_id
    LEFT JOIN first_clicks fc ON s.event_id = fc.event_id
GROUP BY us.segment
ORDER BY us.segment;