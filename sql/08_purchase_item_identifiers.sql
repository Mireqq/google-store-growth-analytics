SELECT
    COALESCE(NULLIF(item.item_id, ''), '[missing item ID]') AS item_id,
    COALESCE(NULLIF(item.item_name, ''), '[missing item name]') AS item_name,

    COUNT(DISTINCT CONCAT(
        user_pseudo_id,
        '-',
        CAST(
            (
                SELECT value.int_value
                FROM UNNEST(event_params)
                WHERE key = 'ga_session_id'
            ) AS STRING
        )
    )) AS purchase_sessions,

    SUM(COALESCE(item.quantity, 0)) AS units_purchased,

    ROUND(
        SUM(COALESCE(item.item_revenue, 0)),
        2
    ) AS item_revenue

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item

WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'
    AND event_name = 'purchase'

GROUP BY
    item_id,
    item_name

ORDER BY
    purchase_sessions DESC

LIMIT 30;