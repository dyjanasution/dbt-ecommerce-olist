WITH orders AS (
    SELECT *
    FROM {{ ref('slv_orders_enriched') }}
    WHERE NOT is_cancelled
),

ref_date AS (
    SELECT MAX(purchased_at) AS ref_ts
    FROM orders
),

customer_summary AS (
    SELECT
        o.customer_unique_id,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        MIN(o.purchased_at)                     AS first_purchase_at,
        MAX(o.purchased_at)                     AS last_purchase_at,
        ROUND(SUM(o.total_payment)::NUMERIC, 2) AS lifetime_value,
        ROUND(AVG(o.total_payment)::NUMERIC, 2) AS avg_order_value,
        ROUND(AVG(o.review_score)::NUMERIC, 2)  AS avg_review_score,
        COUNT(*) FILTER (WHERE o.is_late_delivery) AS late_deliveries_experienced,
        EXTRACT(DAY FROM (r.ref_ts - MAX(o.purchased_at))) AS days_since_last_purchase
    FROM orders o
    CROSS JOIN ref_date r
    GROUP BY o.customer_unique_id, r.ref_ts
),

segmented AS (
    SELECT
        customer_unique_id,
        total_orders,
        first_purchase_at,
        last_purchase_at,
        days_since_last_purchase,
        lifetime_value,
        avg_order_value,
        avg_review_score,
        late_deliveries_experienced,
        CASE
            WHEN total_orders = 1
             AND days_since_last_purchase <= 180   THEN 'new'
            WHEN total_orders >= 2
             AND days_since_last_purchase <= 180   THEN 'returning'
            WHEN total_orders >= 2
             AND days_since_last_purchase BETWEEN 181 AND 365 THEN 'at_risk'
            ELSE 'churned'
        END                                        AS customer_segment,
        RANK() OVER (ORDER BY days_since_last_purchase ASC)  AS recency_rank,
        RANK() OVER (ORDER BY total_orders DESC)             AS frequency_rank,
        RANK() OVER (ORDER BY lifetime_value DESC)           AS monetary_rank
    FROM customer_summary
)

SELECT * FROM segmented
ORDER BY lifetime_value DESC