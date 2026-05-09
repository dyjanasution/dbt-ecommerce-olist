WITH orders AS (
    SELECT *
    FROM {{ ref('slv_orders_enriched') }}
    WHERE NOT is_cancelled
),

monthly AS (
    SELECT
        DATE_TRUNC('month', purchased_at)::DATE             AS month,
        COUNT(DISTINCT order_id)                            AS total_orders,
        COUNT(DISTINCT customer_unique_id)                  AS unique_customers,
        ROUND(SUM(total_payment)::NUMERIC, 2)               AS total_revenue,
        ROUND(AVG(total_payment)::NUMERIC, 2)               AS avg_order_value,
        ROUND(AVG(review_score)::NUMERIC, 2)                AS avg_review_score,
        COUNT(*) FILTER (WHERE is_late_delivery)            AS late_orders,
        ROUND(
            (COUNT(*) FILTER (WHERE is_late_delivery) * 100.0
             / NULLIF(COUNT(*), 0))::NUMERIC, 1
        )                                                   AS late_delivery_rate_pct
    FROM orders
    GROUP BY 1
),

with_growth AS (
    SELECT
        month,
        total_orders,
        unique_customers,
        total_revenue,
        avg_order_value,
        avg_review_score,
        late_orders,
        late_delivery_rate_pct,
        LAG(total_revenue) OVER (ORDER BY month)            AS prev_month_revenue,
        ROUND(
            (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
            / NULLIF(LAG(total_revenue) OVER (ORDER BY month), 0)
            * 100.0
        , 2)                                                AS mom_revenue_growth_pct,
        ROUND(
            SUM(total_revenue) OVER (
                ORDER BY month
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )::NUMERIC, 2
        )                                                   AS cumulative_revenue
    FROM monthly
)

SELECT * FROM with_growth
ORDER BY month