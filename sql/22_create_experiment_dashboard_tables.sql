-- Dashboard tables for the reproducible simulated A/B test.
-- These values are simulated and do not represent a live Google experiment.

CREATE OR REPLACE TABLE
  `grand-magpie-446717-v3.google_store_analytics.dashboard_experiment_variants`
AS
SELECT
  'Control' AS variant,
  5449 AS users,
  1274 AS cart_conversions,
  100 AS cart_removals,
  16 AS purchases,
  53 AS page_errors,
  369.43 AS revenue,
  'Simulated' AS data_type
UNION ALL
SELECT
  'Treatment', 5449, 1394, 123, 28, 57, 605.07, 'Simulated';

CREATE OR REPLACE VIEW
  `grand-magpie-446717-v3.google_store_analytics.dashboard_experiment_metrics`
AS
SELECT
  variant,
  users,
  cart_conversions,
  cart_removals,
  purchases,
  page_errors,
  revenue,
  data_type,
  SAFE_DIVIDE(cart_conversions, users) AS cart_conversion_rate,
  SAFE_DIVIDE(cart_removals, cart_conversions) AS removal_rate,
  SAFE_DIVIDE(purchases, users) AS purchase_conversion_rate,
  SAFE_DIVIDE(page_errors, users) AS page_error_rate,
  SAFE_DIVIDE(revenue, users) AS revenue_per_user
FROM
  `grand-magpie-446717-v3.google_store_analytics.dashboard_experiment_variants`;

CREATE OR REPLACE TABLE
  `grand-magpie-446717-v3.google_store_analytics.dashboard_experiment_results`
AS
SELECT
  0.2295 AS historical_baseline_rate,
  0.2524 AS planned_target_rate,
  5449 AS required_users_per_group,
  10898 AS total_required_users,
  84 AS estimated_experiment_days,
  0.0220 AS absolute_uplift,
  0.0942 AS relative_uplift,
  0.0059 AS confidence_interval_low,
  0.0382 AS confidence_interval_high,
  0.0075 AS p_value,
  0.05 AS alpha,
  0.01 AS minimum_practical_absolute_uplift,
  'Statistically significant, but minimum practical impact is uncertain'
    AS decision,
  'Simulated' AS data_type;
