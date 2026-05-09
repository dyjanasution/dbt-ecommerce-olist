WITH source AS (
    SELECT * FROM {{ source('olist', 'products') }}
),

products AS (
    SELECT
        product_id,
        NULLIF(TRIM(product_category_name), '')     AS category_name_pt,
        product_name_lenght::INT                    AS product_name_length,
        product_description_lenght::INT             AS product_description_length,
        product_photos_qty::INT                     AS photos_qty,
        product_weight_g::NUMERIC                   AS weight_g,
        product_length_cm::NUMERIC                  AS length_cm,
        product_height_cm::NUMERIC                  AS height_cm,
        product_width_cm::NUMERIC                   AS width_cm,
        CASE
            WHEN product_length_cm IS NOT NULL
             AND product_height_cm IS NOT NULL
             AND product_width_cm  IS NOT NULL
            THEN (product_length_cm::NUMERIC
                  * product_height_cm::NUMERIC
                  * product_width_cm::NUMERIC)
        END                                         AS volume_cm3
    FROM source
)

SELECT * FROM products