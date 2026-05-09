WITH source AS (
    SELECT * FROM {{ source('olist', 'order_payments') }}
),

order_payments AS (
    SELECT
        order_id,
        payment_sequential                      AS payment_seq,
        LOWER(TRIM(payment_type))               AS payment_type,
        COALESCE(payment_installments::INT, 1)  AS installments
    FROM source
)

SELECT * FROM order_payments
