WITH source AS (
    SELECT * FROM {{ source('olist', 'product_category_name_translation') }}
),

product_category_name_translation AS (
    SELECT
        NULLIF(TRIM(product_category_name), '')         AS category_name_pt,
        NULLIF(TRIM(product_category_name_english), '') AS category_name_en
    FROM source
)

SELECT * FROM product_category_name_translation