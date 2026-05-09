WITH source AS (
    SELECT * FROM {{ source('olist', 'customers') }}
),

customers AS (
    SELECT
        customer_id,
        customer_unique_id,
        NULLIF(customer_zip_code_prefix, '')        AS zip_code_prefix,
        NULLIF(TRIM(customer_city), '')             AS city,
        NULLIF(UPPER(TRIM(customer_state)), '')     AS state
    FROM source
)

SELECT * FROM customers