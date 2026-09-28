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
        item.item_id,
        item.item_name,
        item.item_revenue

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
        UNNEST(items) AS item

    WHERE
        _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
        AND user_pseudo_id IS NOT NULL
        AND item.item_name IS NOT NULL
),

product_performance AS (
    SELECT
        item_id,
        item_name,

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

        ROUND(
            SUM(
                IF(
                    event_name = 'purchase',
                    COALESCE(item_revenue, 0),
                    0
                )
            ),
            2
        ) AS revenue

    FROM item_events
    WHERE session_id IS NOT NULL
    GROUP BY
        item_id,
        item_name
)

SELECT
    item_id,
    item_name,
    product_view_sessions,
    cart_sessions,
    checkout_sessions,
    purchase_sessions,
    revenue,

    ROUND(
        SAFE_DIVIDE(cart_sessions, product_view_sessions) * 100,
        2
    ) AS view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(purchase_sessions, cart_sessions) * 100,
        2
    ) AS cart_to_purchase_rate,

    ROUND(
        SAFE_DIVIDE(purchase_sessions, product_view_sessions) * 100,
        2
    ) AS product_conversion_rate

FROM product_performance
WHERE product_view_sessions >= 100
ORDER BY product_view_sessions DESC;