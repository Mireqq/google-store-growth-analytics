SELECT
    event_name,
    COUNT(*) AS event_count,

    COUNTIF(ARRAY_LENGTH(items) > 0) AS events_with_items,

    SUM(ARRAY_LENGTH(items)) AS total_item_records,

    COUNTIF(
        ecommerce.purchase_revenue IS NOT NULL
    ) AS events_with_purchase_revenue,

    ROUND(
        SUM(COALESCE(ecommerce.purchase_revenue, 0)),
        2
    ) AS total_purchase_revenue

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`

WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131'

    AND event_name IN (
        'view_item',
        'add_to_cart',
        'begin_checkout',
        'add_shipping_info',
        'add_payment_info',
        'purchase'
    )

GROUP BY event_name
ORDER BY event_count DESC;