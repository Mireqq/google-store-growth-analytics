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

        device.category AS device_category,
        TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
        event_name,
        LOWER(TRIM(item.item_name)) AS product_key,
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

product_session AS (
    SELECT
        session_id,
        product_key,
        ANY_VALUE(device_category) AS device_category,

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

labelled_sessions AS (
    SELECT
        *,
        IF(
            product_key = 'youtube icon tee grey',
            'YouTube Icon Tee Grey',
            'Other products'
        ) AS product_group

    FROM product_session
    WHERE first_view_time IS NOT NULL
)

SELECT
    product_group,
    device_category,

    COUNT(*) AS view_sessions,

    COUNTIF(
        first_cart_time >= first_view_time
    ) AS ordered_cart_sessions,

    COUNTIF(
        purchase_time >= first_view_time
    ) AS ordered_purchase_sessions,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(first_cart_time >= first_view_time),
            COUNT(*)
        ) * 100,
        2
    ) AS ordered_view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(purchase_time >= first_view_time),
            COUNT(*)
        ) * 100,
        2
    ) AS ordered_view_to_purchase_rate,

    ROUND(
        SUM(
            IF(
                purchase_time >= first_view_time,
                purchase_revenue,
                0
            )
        ),
        2
    ) AS same_session_revenue

FROM labelled_sessions

GROUP BY
    product_group,
    device_category

ORDER BY
    device_category,
    product_group;