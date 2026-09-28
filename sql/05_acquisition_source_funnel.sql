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

        traffic_source.source AS first_user_source,
        traffic_source.medium AS first_user_medium,
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
        ANY_VALUE(first_user_source) AS first_user_source,
        ANY_VALUE(first_user_medium) AS first_user_medium,

        MAX(IF(event_name = 'view_item', 1, 0)) AS viewed_product,
        MAX(IF(event_name = 'add_to_cart', 1, 0)) AS added_to_cart,
        MAX(IF(event_name = 'begin_checkout', 1, 0)) AS began_checkout,
        MAX(IF(event_name = 'purchase', 1, 0)) AS purchased

    FROM event_level
    WHERE session_id IS NOT NULL
    GROUP BY session_id
),

source_performance AS (
    SELECT
        COALESCE(first_user_source, 'unknown') AS first_user_source,
        COALESCE(first_user_medium, 'unknown') AS first_user_medium,

        COUNT(*) AS total_sessions,
        COUNTIF(viewed_product = 1) AS product_view_sessions,
        COUNTIF(added_to_cart = 1) AS cart_sessions,
        COUNTIF(began_checkout = 1) AS checkout_sessions,
        COUNTIF(purchased = 1) AS purchase_sessions

    FROM session_level
    GROUP BY
        first_user_source,
        first_user_medium
)

SELECT
    first_user_source,
    first_user_medium,
    total_sessions,
    product_view_sessions,
    cart_sessions,
    checkout_sessions,
    purchase_sessions,

    ROUND(
        SAFE_DIVIDE(product_view_sessions, total_sessions) * 100,
        2
    ) AS product_view_rate,

    ROUND(
        SAFE_DIVIDE(cart_sessions, product_view_sessions) * 100,
        2
    ) AS view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(checkout_sessions, cart_sessions) * 100,
        2
    ) AS cart_to_checkout_rate,

    ROUND(
        SAFE_DIVIDE(purchase_sessions, checkout_sessions) * 100,
        2
    ) AS checkout_to_purchase_rate,

    ROUND(
        SAFE_DIVIDE(purchase_sessions, total_sessions) * 100,
        2
    ) AS overall_conversion_rate

FROM source_performance
WHERE total_sessions >= 500
ORDER BY total_sessions DESC;