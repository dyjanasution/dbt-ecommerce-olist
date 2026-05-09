WITH source AS (
    SELECT * FROM {{ source('olist', 'order_items') }}
),

order_itemsd AS (
    SELECT
        order_id,
        order_item_id                               AS item_sequence,
        product_id,
        seller_id,
        NULLIF(shipping_limit_date, '')::TIMESTAMPTZ AS shipping_limit_at,
        price::NUMERIC                              AS item_price,
        freight_value::NUMERIC                      AS freight_value
    FROM source
)

SELECT * FROM order_items