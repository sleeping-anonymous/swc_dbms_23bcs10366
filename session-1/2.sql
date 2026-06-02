-- https://platform.stratascratch.com/coding/10568-daily-revenue?code_type=1
WITH qualifying_purchases AS (
    SELECT transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
        AND country = 'US'
        AND type = 'purchase'
        AND status = 'completed'
        AND transaction_date BETWEEN DATE '2025-04-15' AND DATE '2025-04-28'
),
revenue_events AS (
    -- purchases
    SELECT transaction_date,
        amount AS revenue
    FROM qualifying_purchases
    UNION ALL
    -- refunds linked to those purchases
    SELECT r.transaction_date,
        - r.amount AS revenue
    FROM product_sales r
        JOIN qualifying_purchases p ON r.original_transaction_id = p.transaction_id
    WHERE r.type = 'refund'
        AND r.status = 'completed'
),
daily_revenue AS (
    SELECT transaction_date,
        SUM(revenue) AS daily_net_revenue
    FROM revenue_events
    GROUP BY transaction_date
),
dates AS (
    SELECT generate_series(
            DATE '2025-04-15',
            DATE '2025-04-28',
            INTERVAL '1 day'
        )::date AS transaction_date
)
SELECT d.transaction_date,
    COALESCE(dr.daily_net_revenue, 0) AS daily_net_revenue
FROM dates d
    LEFT JOIN daily_revenue dr ON d.transaction_date = dr.transaction_date
ORDER BY d.transaction_date;