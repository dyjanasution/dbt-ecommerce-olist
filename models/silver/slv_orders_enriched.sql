WITH orders AS (
    SELECT * FROM {{ ref('brz_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('brz_customers') }}
),

order_items_agg AS (
    SELECT
        order_id,
        COUNT(*)                        AS total_items,
        SUM(item_price)                 AS items_revenue,
        SUM(freight_value)              AS total_freight,
        SUM(item_total_cost)            AS total_order_value,
        AVG(item_price)                 AS avg_item_price
    FROM {{ ref('brz_order_items') }}
    GROUP BY order_id
),

payments_agg AS (
    SELECT
        order_id,
        SUM(payment_value)                                      AS total_payment,
        MAX(installments)                                       AS max_installments,
        SUM(payment_value) FILTER (WHERE is_credit_card)        AS credit_card_amount,
        SUM(payment_value) FILTER (WHERE is_boleto)             AS boleto_amount,
        COUNT(DISTINCT payment_type)                            AS payment_methods_used
    FROM {{ ref('brz_order_payments') }}
    GROUP BY order_id
),

reviews AS (
    SELECT DISTINCT ON (order_id)
        order_id,
        review_score,
        is_low_score,
        review_title,
        review_message,
        review_created_at
    FROM {{ ref('brz_order_reviews') }}
    ORDER BY order_id, review_created_at DESC
),

enriched AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_unique_id,
        c.city                                                      AS customer_city,
        c.state                                                     AS customer_state,
        o.order_status,
        o.is_delivered,
        o.is_cancelled,
        o.purchased_at,
        o.approved_at,
        o.delivered_to_carrier_at,
        o.delivered_to_customer_at,
        o.estimated_delivery_at,

        -- Delivery delay in days
        CASE
            WHEN o.delivered_to_customer_at IS NOT NULL
             AND o.estimated_delivery_at    IS NOT NULL
            THEN EXTRACT(EPOCH FROM (
                    o.delivered_to_customer_at - o.estimated_delivery_at
                 )) / 86400.0
        END                                                         AS delivery_delay_days,

        -- Late delivery boolean
        CASE
            WHEN o.delivered_to_customer_at > o.estimated_delivery_at
            THEN TRUE ELSE FALSE
        END                                                         AS is_late_delivery,

        -- Approval lag in hours
        CASE
            WHEN o.approved_at IS NOT NULL
            THEN EXTRACT(EPOCH FROM (
                    o.approved_at - o.purchased_at
                 )) / 3600.0
        END                                                         AS approval_lag_hours,

        oi.total_items,
        oi.items_revenue,
        oi.total_freight,
        oi.total_order_value,
        oi.avg_item_price,
        pay.total_payment,
        pay.max_installments,
        pay.credit_card_amount,
        pay.boleto_amount,
        pay.payment_methods_used,
        r.review_score,
        r.is_low_score,
        r.review_title,
        r.review_message

    FROM orders o
    LEFT JOIN customers c           ON c.customer_id    = o.customer_id
    LEFT JOIN order_items_agg oi    ON oi.order_id      = o.order_id
    LEFT JOIN payments_agg pay      ON pay.order_id     = o.order_id
    LEFT JOIN reviews r             ON r.order_id       = o.order_id
)

SELECT * FROM enriched