-- Validation checks used before connecting the views to Looker Studio.

-- Funnel ordering must hold at every stage.
SELECT
  LOGICAL_AND(product_view_sessions <= total_sessions) AS views_valid,
  LOGICAL_AND(cart_sessions <= product_view_sessions) AS carts_valid,
  LOGICAL_AND(checkout_sessions <= cart_sessions) AS checkout_valid,
  LOGICAL_AND(purchase_sessions <= checkout_sessions) AS purchases_valid
FROM
  `grand-magpie-446717-v3.google_store_analytics.dashboard_sessions`;

-- Product journeys must be ordered and non-negative.
SELECT
  COUNTIF(cart_sessions > view_sessions) AS products_with_invalid_carts,
  COUNTIF(purchase_sessions > cart_sessions) AS products_with_invalid_purchases,
  COUNTIF(item_revenue < 0) AS products_with_negative_revenue
FROM
  `grand-magpie-446717-v3.google_store_analytics.dashboard_products`;

-- Confirm the simulated experiment is balanced and explicitly labelled.
SELECT
  COUNT(DISTINCT variant) AS variants,
  MIN(users) AS minimum_variant_users,
  MAX(users) AS maximum_variant_users,
  COUNTIF(data_type != 'Simulated') AS unlabelled_rows
FROM
  `grand-magpie-446717-v3.google_store_analytics.dashboard_experiment_metrics`;
