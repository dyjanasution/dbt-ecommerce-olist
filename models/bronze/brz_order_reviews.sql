WITH source AS (
    SELECT * FROM {{ source('olist', 'order_reviews') }}
),

order_reviews AS (
    SELECT
        review_id,
        order_id,
        review_score::INT                                           AS review_score,
        NULLIF(TRIM(review_comment_title), '')                      AS review_title,
        NULLIF(TRIM(review_comment_message), '')                    AS review_message,
        NULLIF(review_creation_date, '')::TIMESTAMPTZ               AS review_created_at,
        NULLIF(review_answer_timestamp, '')::TIMESTAMPTZ            AS review_answered_at
    FROM source
)

SELECT * FROM order_reviews