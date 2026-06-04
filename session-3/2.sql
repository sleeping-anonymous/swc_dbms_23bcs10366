WITH engagement AS (
    SELECT product_id,
        product_name,
        month_start,
        monthly_active_users AS u1,
        LEAD(monthly_active_users, 1) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u2,
        LEAD(monthly_active_users, 2) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u3,
        LEAD(monthly_active_users, 3) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u4,
        LEAD(monthly_active_users, 4) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u5,
        LEAD(monthly_active_users, 5) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u6,
        LEAD(monthly_active_users, 6) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS u7,
        LEAD(month_start, 4) OVER (
            PARTITION BY product_id
            ORDER BY month_start
        ) AS growth_resumed_month
    FROM product_engagement
)
SELECT product_name,
    month_start AS decline_started_month,
    growth_resumed_month,
    ROUND((u7 - u4) * 1.0 / u4, 4) AS growth_ratio
FROM engagement
WHERE u1 > u2
    AND u2 > u3
    AND u3 > u4
    AND u4 < u5
    AND u5 < u6
    AND u6 < u7
ORDER BY product_name;