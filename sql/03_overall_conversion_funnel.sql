WITH event_level AS (
    SELECT
        CONCAT(
            user_pseudo_id,
            '-',
            CAST(
                (
                    SELECT value.int_value
                    FROM UNNEST(event_params)
                    WHERE key = 'ga_session_id'
                ) AS STRING
            )
        ) AS session_id,
        event_name
    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
    WHERE
        _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
        AND user_pseudo_id IS NOT NULL
),

session_level AS (
    SELECT
        session_id,
        MAX(IF(event_name = 'view_item', 1, 0)) AS viewed_product,
        MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
        MAX(IF(event_name = 'begin_checkout', 1, 0)) AS began_checkout,
        MAX(IF(event_name = 'purchase', 1, 0)) AS purchased
    FROM event_level
    WHERE session_id IS NOT NULL
    GROUP BY session_id
)

SELECT
    COUNT(*) AS total_sessions,
    COUNTIF(viewed_product = 1) AS product_view_sessions,
    COUNTIF(added_to_cart = 1) AS cart_sessions,
    COUNTIF(began_checkout = 1) AS checkout_sessions,
    COUNTIF(purchased = 1) AS purchase_sessions,

    ROUND(
        SAFE_DIVIDE(COUNTIF(viewed_product = 1), COUNT(*)) * 100,
        2
    ) AS product_view_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(added_to_cart = 1),
            COUNTIF(viewed_product = 1)
        ) * 100,
        2
    ) AS view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(began_checkout = 1),
            COUNTIF(added_to_cart = 1)
        ) * 100,
        2
    ) AS cart_to_checkout_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(purchased = 1),
            COUNTIF(began_checkout = 1)
        ) * 100,
        2
    ) AS checkout_to_purchase_rate,

    ROUND(
        SAFE_DIVIDE(COUNTIF(purchased = 1), COUNT(*)) * 100,
        2
    ) AS overall_conversion_rate

FROM session_level;