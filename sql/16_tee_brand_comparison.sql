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
        LOWER(TRIM(item.item_name)) AS product_key,
        item.item_name AS product_name,
        item.price,

        CASE
            WHEN LOWER(item.item_name) LIKE '%youtube%'
                THEN 'YouTube'
            WHEN LOWER(item.item_name) LIKE '%android%'
                THEN 'Android'
            WHEN LOWER(item.item_name) LIKE '%google%'
                THEN 'Google'
            ELSE 'Other'
        END AS merchandise_brand

    FROM
        `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
        UNNEST(items) AS item

    WHERE
        _TABLE_SUFFIX BETWEEN '20201123' AND '20210131'
        AND user_pseudo_id IS NOT NULL
        AND item.item_name IS NOT NULL
        AND (
            LOWER(item.item_name) LIKE '%tee%'
            OR LOWER(item.item_name) LIKE '%t-shirt%'
        )
),

product_session AS (
    SELECT
        session_id,
        product_key,
        ANY_VALUE(product_name) AS product_name,
        ANY_VALUE(merchandise_brand) AS merchandise_brand,

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

        AVG(IF(
            event_name = 'view_item',
            price,
            NULL
        )) AS viewed_price

    FROM item_events
    WHERE session_id IS NOT NULL
    GROUP BY
        session_id,
        product_key
),

eligible_products AS (
    SELECT
        product_key
    FROM product_session
    GROUP BY product_key
    HAVING COUNTIF(first_view_time IS NOT NULL) >= 500
)

SELECT
    merchandise_brand,

    COUNT(DISTINCT product_key) AS products,

    COUNTIF(
        first_view_time IS NOT NULL
    ) AS view_sessions,

    COUNTIF(
        first_cart_time >= first_view_time
    ) AS ordered_cart_sessions,

    COUNTIF(
        purchase_time >= first_view_time
    ) AS ordered_purchase_sessions,

    ROUND(
        AVG(viewed_price),
        2
    ) AS average_viewed_price,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(first_cart_time >= first_view_time),
            COUNTIF(first_view_time IS NOT NULL)
        ) * 100,
        2
    ) AS ordered_view_to_cart_rate,

    ROUND(
        SAFE_DIVIDE(
            COUNTIF(purchase_time >= first_view_time),
            COUNTIF(first_view_time IS NOT NULL)
        ) * 100,
        2
    ) AS ordered_view_to_purchase_rate

FROM product_session

WHERE
    product_key IN (
        SELECT product_key
        FROM eligible_products
    )

GROUP BY merchandise_brand

ORDER BY view_sessions DESC;