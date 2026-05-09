WITH source AS (
    SELECT * FROM {{ source('olist', 'geolocation') }}
),

geolocation AS (
    SELECT
        NULLIF(geolocation_zip_code_prefix, '')     AS zip_code_prefix,
        geolocation_lat::NUMERIC                    AS latitude,
        geolocation_lng::NUMERIC                    AS longitude,
        NULLIF(TRIM(geolocation_city), '')          AS city,
        NULLIF(UPPER(TRIM(geolocation_state)), '')  AS state
    FROM source
)

SELECT * FROM geolocation