SELECT
    COUNT(*) AS total_events,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    COUNT(DISTINCT event_date) AS active_days,
    MIN(PARSE_DATE('%Y%m%d', event_date)) AS start_date,
    MAX(PARSE_DATE('%Y%m%d', event_date)) AS end_date
FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
WHERE
    _TABLE_SUFFIX BETWEEN '20201101' AND '20210131';