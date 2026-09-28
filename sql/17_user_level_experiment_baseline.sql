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
        LOWER(TRIM(item.item_name)) AS product_key

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
        )) AS first_cart_time

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

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(first_cart_time >= first_view_time),
            COUNT(*)
        ) * 100,
        2
    ) AS user_conversion_rate

FROM first_eligible_session

WHERE exposure_number = 1;