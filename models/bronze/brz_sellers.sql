WITH source AS (
    SELECT * FROM {{ source('olist', 'sellers') }}
),

sellers AS (
    SELECT
        seller_id,
        NULLIF(seller_zip_code_prefix, '')      AS zip_code_prefix,
        NULLIF(TRIM(seller_city), '')           AS city,
        NULLIF(UPPER(TRIM(seller_state)), '')   AS state
    FROM source
)

SELECT * FROM sellers