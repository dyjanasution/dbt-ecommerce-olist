WITH order_items AS (
    SELECT * FROM {{ ref('brz_order_items') }}
),

orders AS (
    SELECT order_id
    FROM {{ ref('orders') }}
    WHERE NOT is_cancelled
),

products AS (
    SELECT
        p.product_id,
        p.category_name_pt,
        t.category_name_en,
        p.weight_g,
        p.volume_cm3
    FROM {{ ref('products') }} p
    LEFT JOIN {{ ref('product_category_translation') }} t
        ON t.category_name_pt = p.category_name_pt
),

reviews AS (
    SELECT DISTINCT ON (order_id)
        order_id,
        review_score
    FROM {{ ref('order_reviews') }}
    ORDER BY order_id, review_created_at DESC
),

valid_items AS (
    SELECT
        oi.product_id,
        oi.order_id,
        oi.item_price,
        oi.freight_value,
        r.review_score
    FROM order_items oi
    JOIN orders o       ON o.order_id     = oi.order_id
    LEFT JOIN reviews r ON r.order_id     = oi.order_id
),

product_agg AS (
    SELECT
        vi.product_id,
        p.category_name_pt,
        p.category_name_en,
        p.weight_g,
        p.volume_cm3,
        COUNT(*)                                AS units_sold,
        COUNT(DISTINCT vi.order_id)             AS total_orders,
        ROUND(SUM(vi.item_price)::NUMERIC, 2)   AS total_revenue,
        ROUND(AVG(vi.item_price)::NUMERIC, 2)   AS avg_price,
        ROUND(AVG(vi.freight_value)::NUMERIC, 2) AS avg_freight,
        ROUND(AVG(vi.review_score)::NUMERIC, 2) AS avg_review_score,
        COUNT(*) FILTER (WHERE vi.review_score <= 2) AS low_score_count
    FROM valid_items vi
    LEFT JOIN products p ON p.product_id = vi.product_id
    GROUP BY
        vi.product_id,
        p.category_name_pt,
        p.category_name_en,
        p.weight_g,
        p.volume_cm3
)

SELECT
    product_id,
    category_name_pt,
    category_name_en,
    weight_g,
    volume_cm3,
    units_sold,
    total_orders,
    total_revenue,
    avg_price,
    avg_freight,
    avg_review_score,
    low_score_count,
    RANK() OVER (ORDER BY total_revenue DESC)       AS product_revenue_rank,
    RANK() OVER (ORDER BY units_sold DESC)          AS product_units_rank,
    RANK() OVER (ORDER BY avg_review_score DESC)    AS product_review_rank,
    RANK() OVER (
        PARTITION BY category_name_en
        ORDER BY total_revenue DESC
    )                                               AS rank_within_category
FROM product_agg
ORDER BY product_revenue_rank