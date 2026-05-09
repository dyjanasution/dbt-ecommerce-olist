WITH order_items AS (
    SELECT * FROM {{ ref('brz_order_items') }}
),

orders AS (
    SELECT * FROM {{ ref('brz_orders') }}
    WHERE NOT is_cancelled
),

reviews AS (
    SELECT DISTINCT ON (order_id)
        order_id,
        review_score,
        is_low_score
    FROM {{ ref('brz_order_reviews') }}
    ORDER BY order_id, review_created_at DESC
),

products AS (
    SELECT product_id, category_name_pt
    FROM {{ ref('brz_products') }}
),

item_grain AS (
    SELECT
        oi.seller_id,
        oi.order_id,
        oi.item_price,
        oi.freight_value,
        o.purchased_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at,
        r.review_score,
        r.is_low_score,
        p.category_name_pt,
        CASE
            WHEN o.delivered_to_customer_at > o.estimated_delivery_at
            THEN TRUE ELSE FALSE
        END AS is_late
    FROM order_items oi
    JOIN orders o        ON o.order_id     = oi.order_id
    LEFT JOIN reviews r  ON r.order_id     = oi.order_id
    LEFT JOIN products p ON p.product_id   = oi.product_id
),

seller_agg AS (
    SELECT
        seller_id,
        COUNT(DISTINCT order_id)                        AS total_orders,
        COUNT(*)                                        AS total_items_sold,
        ROUND(SUM(item_price)::NUMERIC, 2)              AS total_revenue,
        ROUND(AVG(item_price)::NUMERIC, 2)              AS avg_item_price,
        ROUND(SUM(freight_value)::NUMERIC, 2)           AS total_freight_collected,
        ROUND(AVG(review_score)::NUMERIC, 2)            AS avg_review_score,
        COUNT(*) FILTER (WHERE is_low_score)            AS low_score_count,
        ROUND(
            (COUNT(*) FILTER (WHERE is_low_score) * 100.0
             / NULLIF(COUNT(*), 0))::NUMERIC, 1
        )                                               AS low_score_rate_pct,
        COUNT(DISTINCT order_id) FILTER (WHERE is_late) AS late_orders,
        ROUND(
            (COUNT(DISTINCT order_id) FILTER (WHERE is_late) * 100.0
             / NULLIF(COUNT(DISTINCT order_id), 0))::NUMERIC, 1
        )                                               AS late_delivery_rate_pct,
        MIN(purchased_at)                               AS first_sale_at,
        MAX(purchased_at)                               AS last_sale_at,
        MODE() WITHIN GROUP (ORDER BY category_name_pt) AS top_category
    FROM item_grain
    GROUP BY seller_id
)

SELECT * FROM seller_agg