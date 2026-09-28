-- Ordered same-session product journey used by the Product Performance page.
-- Source: Google Analytics 4 obfuscated ecommerce sample.

CREATE OR REPLACE VIEW
  `grand-magpie-446717-v3.google_store_analytics.dashboard_products`
AS

WITH item_events AS (
  SELECT
    CONCAT(
      user_pseudo_id,
      '-',
      CAST((
        SELECT value.int_value
        FROM UNNEST(event_params)
        WHERE key = 'ga_session_id'
      ) AS STRING)
    ) AS session_id,
    event_timestamp,
    event_name,
    COALESCE(NULLIF(item.item_name, ''), '(not set)') AS product_name,
    CASE
      WHEN REGEXP_CONTAINS(LOWER(COALESCE(item.item_name, '')), r'youtube')
        THEN 'YouTube'
      WHEN REGEXP_CONTAINS(LOWER(COALESCE(item.item_name, '')), r'android')
        THEN 'Android'
      WHEN REGEXP_CONTAINS(
        LOWER(COALESCE(item.item_name, '')),
        r'(^google|super g|noogler)'
      ) THEN 'Google'
      WHEN item.item_brand IS NULL
        OR item.item_brand = ''
        OR item.item_brand = '(not set)'
        THEN 'Other'
      ELSE item.item_brand
    END AS merchandise_brand,
    COALESCE(item.quantity, 0) AS quantity,
    COALESCE(item.item_revenue, 0) AS item_revenue
  FROM
    `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`,
    UNNEST(items) AS item
  WHERE
    _TABLE_SUFFIX BETWEEN '20201123' AND '20210131'
    AND event_name IN ('view_item', 'add_to_cart', 'purchase')
    AND item.item_name IS NOT NULL
),

first_views AS (
  SELECT
    session_id,
    product_name,
    ANY_VALUE(merchandise_brand) AS merchandise_brand,
    MIN(event_timestamp) AS first_view_time
  FROM item_events
  WHERE event_name = 'view_item'
  GROUP BY session_id, product_name
),

view_to_cart AS (
  SELECT
    views.session_id,
    views.product_name,
    views.merchandise_brand,
    views.first_view_time,
    MIN(IF(
      events.event_name = 'add_to_cart'
      AND events.event_timestamp >= views.first_view_time,
      events.event_timestamp,
      NULL
    )) AS first_cart_time
  FROM first_views AS views
  LEFT JOIN item_events AS events
    ON views.session_id = events.session_id
    AND views.product_name = events.product_name
  GROUP BY
    views.session_id,
    views.product_name,
    views.merchandise_brand,
    views.first_view_time
),

product_summary AS (
  SELECT
    journey.product_name,
    journey.merchandise_brand,
    COUNT(DISTINCT journey.session_id) AS view_sessions,
    COUNT(DISTINCT IF(
      journey.first_cart_time IS NOT NULL,
      journey.session_id,
      NULL
    )) AS cart_sessions,
    COUNT(DISTINCT IF(
      events.event_name = 'purchase'
      AND journey.first_cart_time IS NOT NULL
      AND events.event_timestamp >= journey.first_cart_time,
      journey.session_id,
      NULL
    )) AS purchase_sessions,
    SUM(IF(
      events.event_name = 'purchase'
      AND journey.first_cart_time IS NOT NULL
      AND events.event_timestamp >= journey.first_cart_time,
      events.quantity,
      0
    )) AS units_purchased,
    ROUND(SUM(IF(
      events.event_name = 'purchase'
      AND journey.first_cart_time IS NOT NULL
      AND events.event_timestamp >= journey.first_cart_time,
      events.item_revenue,
      0
    )), 2) AS item_revenue
  FROM view_to_cart AS journey
  LEFT JOIN item_events AS events
    ON journey.session_id = events.session_id
    AND journey.product_name = events.product_name
  GROUP BY journey.product_name, journey.merchandise_brand
)

SELECT
  product_name,
  merchandise_brand,
  view_sessions,
  cart_sessions,
  purchase_sessions,
  units_purchased,
  item_revenue,
  ROUND(100 * SAFE_DIVIDE(cart_sessions, view_sessions), 2)
    AS view_to_cart_rate,
  ROUND(100 * SAFE_DIVIDE(purchase_sessions, view_sessions), 2)
    AS view_to_purchase_rate
FROM product_summary
WHERE view_sessions > 0;
