WITH item_events AS (
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

        event_name,
        TRIM(item.item_name) AS product_name,
        LOWER(TRIM(item.item_name)) AS product_key,
        COALESCE(item.quantity, 0) AS quantity,
        COALESCE(item.item_revenue, 0) AS item_revenue

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
        UNNEST(items) AS item

    WHERE
        _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
        AND user_pseudo_id IS NOT NULL
        AND item.item_name IS NOT NULL
        AND TRIM(item.item_name) NOT IN ('', '(not set)')
),

product_performance AS (
    SELECT
        product_key,
        ANY_VALUE(product_name) AS product_name,

        COUNT(DISTINCT IF(
            event_name = 'view_item',
            session_id,
            NULL
        )) AS product_view_sessions,

        COUNT(DISTINCT IF(
            event_name = 'add_to_cart',
            session_id,
            NULL
        )) AS cart_sessions,

        COUNT(DISTINCT IF(
            event_name = 'begin_checkout',
            session_id,
            NULL
        )) AS checkout_sessions,

        COUNT(DISTINCT IF(
            event_name = 'purchase',
            session_id,
            NULL
        )) AS purchase_sessions,

        SUM(
            IF(event_name = 'purchase', quantity, 0)
        ) AS units_purchased,

        ROUND(
            SUM(IF(event_name = 'purchase', item_revenue, 0)),
            2
        ) AS revenue

    FROM item_events
    WHERE session_id IS NOT NULL
    GROUP BY product_key
)

SELECT
    product_name,
    product_view_sessions,
    cart_sessions,
    checkout_sessions,
    purchase_sessions,
    units_purchased,
    revenue,

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
        SAFE_DIVIDE(purchase_sessions, product_view_sessions) * 100,
        2
    ) AS product_conversion_rate,

    ROUND(
        SAFE_DIVIDE(revenue, purchase_sessions),
        2
    ) AS revenue_per_purchase_session

FROM product_performance

WHERE product_view_sessions >= 100

ORDER BY product_view_sessions DESC;