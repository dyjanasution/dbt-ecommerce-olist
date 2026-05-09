WITH source AS (
    SELECT * FROM {{ source('olist', 'orders') }}
),

orders AS (
    SELECT
        order_id,
        customer_id,
        LOWER(order_status)                                     AS order_status,
        order_purchase_timestamp::TIMESTAMPTZ                   AS purchased_at,
        NULLIF(order_approved_at, '')::TIMESTAMPTZ              AS approved_at,
        NULLIF(order_delivered_carrier_date, '')::TIMESTAMPTZ   AS delivered_to_carrier_at,
        NULLIF(order_delivered_customer_date, '')::TIMESTAMPTZ  AS delivered_to_customer_at,
        NULLIF(order_estimated_delivery_date, '')::TIMESTAMPTZ  AS estimated_delivery_at
    FROM source
)

SELECT * FROM orders