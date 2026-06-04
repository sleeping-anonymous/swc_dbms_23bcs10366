WITH first_purchase AS (
    SELECT user_id,
        MIN(created_at) AS first_purchase_date
    FROM amazon_transactions
    GROUP BY user_id
)
SELECT DISTINCT a.user_id
FROM amazon_transactions a
    JOIN first_purchase f ON a.user_id = f.user_id
WHERE a.created_at > f.first_purchase_date
    AND a.created_at <= f.first_purchase_date + INTERVAL '7 days'
ORDER BY a.user_id;