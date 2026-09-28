WITH item_events AS (
    SELECT
        user_pseudo_id,

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
        COALESCE(item.item_revenue, 0) AS item_revenue

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
        UNNEST(items) AS item

    WHERE
        _TABLE_SUFFIX BETWEEN '20201123' AND '20210131'
        AND user_pseudo_id IS NOT NULL
        AND LOWER(TRIM(item.item_name)) IN (
            'youtube icon tee grey',
            'youtube icon tee charcoal'
        )
),

session_funnel AS (
    SELECT
        user_pseudo_id,
        session_id,

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
        user_pseudo_id,
        session_id
),

first_eligible_session AS (
    SELECT
        *,

        ROW_NUMBER() OVER (
            PARTITION BY user_pseudo_id
            ORDER BY first_view_time
        ) AS exposure_number

    FROM session_funnel
    WHERE first_view_time IS NOT NULL
)

SELECT
    COUNT(*) AS eligible_users,

    COUNTIF(
        first_cart_time >= first_view_time
    ) AS converted_users,

    COUNTIF(
        first_cart_time >= first_view_time
        AND purchase_time >= first_cart_time
    ) AS complete_purchase_users,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(
                first_cart_time >= first_view_time
                AND purchase_time >= first_cart_time
            ),
            COUNTIF(first_cart_time >= first_view_time)
        ) * 100,
        2
    ) AS cart_to_purchase_rate,

    ROUND(
        SUM(
            IF(
                first_cart_time >= first_view_time
                AND purchase_time >= first_cart_time,
                purchase_revenue,
                0
            )
        ),
        2
    ) AS complete_purchase_revenue

FROM first_eligible_session
WHERE exposure_number = 1;