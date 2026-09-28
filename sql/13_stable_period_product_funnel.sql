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

        TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
        event_name,
        TRIM(item.item_name) AS product_name,
        LOWER(TRIM(item.item_name)) AS product_key,
        COALESCE(item.item_revenue, 0) AS item_revenue

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
        UNNEST(items) AS item

    WHERE
        _TABLE_SUFFIX BETWEEN '20201123' AND '20210131'
        AND user_pseudo_id IS NOT NULL
        AND item.item_name IS NOT NULL
        AND TRIM(item.item_name) NOT IN ('', '(not set)')
),

product_session AS (
    SELECT
        session_id,
        product_key,
        ANY_VALUE(product_name) AS product_name,

        MIN(IF(
            event_name = 'view_item',
            event_timestamp,
            NULL
        )) AS first_view_time,

        MIN(IF(
            event_name = 'add_to_cart',
            event_timestamp,
            NULL
        )) AS first_cart_time,

        MIN(IF(
            event_name = 'purchase',
            event_timestamp,
            NULL
        )) AS purchase_time,

        SUM(IF(
            event_name = 'purchase',
            item_revenue,
            0
        )) AS purchase_revenue

    FROM item_events
    WHERE session_id IS NOT NULL
    GROUP BY
        session_id,
        product_key
),

product_summary AS (
    SELECT
        product_key,
        ANY_VALUE(product_name) AS product_name,

        COUNTIF(
            first_view_time IS NOT NULL
        ) AS view_sessions,

        COUNTIF(
            first_view_time IS NOT NULL
            AND first_cart_time >= first_view_time
        ) AS ordered_cart_sessions,

        COUNTIF(
            first_view_time IS NOT NULL
            AND purchase_time >= first_view_time
        ) AS ordered_purchase_sessions,

        COUNTIF(
            first_view_time IS NOT NULL
            AND first_cart_time >= first_view_time
            AND purchase_time >= first_cart_time
        ) AS complete_funnel_sessions,

        ROUND(
            SUM(
                IF(
                    first_view_time IS NOT NULL
                    AND purchase_time >= first_view_time,
                    purchase_revenue,
                    0
                )
            ),
            2
        ) AS same_session_revenue

    FROM product_session
    GROUP BY product_key
)

SELECT
    product_name,
    view_sessions,
    ordered_cart_sessions,
    ordered_purchase_sessions,
    complete_funnel_sessions,
    same_session_revenue,

    ROUND(
        SAFE_DIVIDE(ordered_cart_sessions, view_sessions) * 100,
        2
    ) AS ordered_view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(ordered_purchase_sessions, view_sessions) * 100,
        2
    ) AS ordered_view_to_purchase_rate,

    ROUND(
        SAFE_DIVIDE(
            complete_funnel_sessions,
            ordered_cart_sessions
        ) * 100,
        2
    ) AS ordered_cart_to_purchase_rate

FROM product_summary

WHERE view_sessions >= 100

ORDER BY view_sessions DESC;