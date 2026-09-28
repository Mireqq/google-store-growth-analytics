SELECT
    event_name,

    COALESCE(NULLIF(item.item_id, ''), '[missing]') AS item_id,

    COALESCE(
        NULLIF(item.item_variant, ''),
        '[missing]'
    ) AS item_variant,

    COALESCE(
        NULLIF(item.item_category, ''),
        '[missing]'
    ) AS item_category,

    COUNT(*) AS item_records,

    ROUND(MIN(item.price), 2) AS minimum_price,
    ROUND(AVG(item.price), 2) AS average_price,
    ROUND(MAX(item.price), 2) AS maximum_price

FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item

WHERE
    _TABLE_SUFFIX BETWEEN '20201123' AND '20210131'

    AND LOWER(TRIM(item.item_name)) =
        'youtube icon tee grey'

GROUP BY
    event_name,
    item_id,
    item_variant,
    item_category

ORDER BY
    event_name,
    item_records DESC;