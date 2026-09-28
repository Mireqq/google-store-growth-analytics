# SQL query index

Run the exploratory queries individually in BigQuery. The numbered order documents how the analysis developed from broad dataset understanding to a dashboard-ready product experiment.

| File | Purpose |
|---|---|
| `01_dataset_overview.sql` | Confirm the source date range, event volume and user coverage |
| `02_event_inventory.sql` | Inventory ecommerce event names and counts |
| `03_overall_conversion_funnel.sql` | Calculate the overall session funnel |
| `04_device_conversion_funnel.sql` | Compare funnel performance by device |
| `05_acquisition_source_funnel.sql` | Compare acquisition-source performance |
| `06_product_performance.sql` | Produce the initial product-performance analysis |
| `07_item_data_validation.sql` | Inspect item-level coverage and quality |
| `08_purchase_item_identifiers.sql` | Validate purchase-item identifiers |
| `09_corrected_product_performance.sql` | Correct the initial product logic |
| `10_strict_product_funnel.sql` | Enforce ordered product journeys |
| `11_target_product_device_comparison.sql` | Compare target products across devices |
| `12_target_product_weekly_trend.sql` | Analyse weekly target-product behaviour |
| `13_stable_period_product_funnel.sql` | Restrict the product funnel to reliable tracking dates |
| `14_target_product_metadata.sql` | Inspect metadata for target products |
| `15_youtube_apparel_comparison.sql` | Compare YouTube apparel products |
| `16_tee_brand_comparison.sql` | Compare tee performance across brands |
| `17_user_level_experiment_baseline.sql` | Create the user-level experiment baseline |
| `18_user_level_guardrail_baseline.sql` | Create historical guardrail baselines |
| `19_create_session_funnel_view.sql` | Validate the materialised session-funnel output |
| `20_create_dashboard_sessions_view.sql` | Create the dashboard-ready session view |
| `21_create_dashboard_products_view.sql` | Create the ordered product-journey view |
| `22_create_experiment_dashboard_tables.sql` | Create simulated experiment dashboard sources |
| `23_validation_checks.sql` | Run final funnel, product and experiment checks |

The first 20 files are the original saved BigQuery queries. Files 21–23 package the final Looker Studio sources and portfolio validation checks.
