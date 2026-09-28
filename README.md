# Google Merchandise Store Growth Analytics

An end-to-end product analytics case study using the public Google Analytics 4 ecommerce sample dataset.

The project combines **BigQuery SQL, Python experimentation and a four-page Looker Studio dashboard** to analyse customer behaviour, identify ecommerce funnel friction and propose a measurable growth experiment.

> **Important:** The A/B-test observations in this project are simulated for demonstration purposes. They do not represent a live experiment conducted by Google.

## Business objective

The analysis answers four key product and growth questions:

1. How is the store performing across devices and acquisition channels?
2. Where do customers leave the ecommerce conversion funnel?
3. Which products and brands generate strong customer interest but weak purchase completion?
4. Could clearer size-and-fit information improve YouTube apparel view-to-cart conversion without negatively affecting important guardrail metrics?

## Executive findings

- The dataset contains **360,129 sessions**, **270,154 users**, **4,848 purchasing sessions** and **$362,165 in revenue**.
- During the reliable tracking period, only **20.69%** of sessions reached a product page.
- Among product viewers, **24.94%** added an item to their cart.
- YouTube Icon Tee Grey and Charcoal generated **17,916 ordered product-view sessions**, while fewer than **24%** progressed to cart and fewer than **0.5%** completed an ordered same-session purchase journey.
- In the simulated experiment, view-to-cart conversion increased from **23.38%** to **25.58%**.
- The estimated uplift was **2.20 percentage points** with a 95% confidence interval of **+0.59 to +3.82 percentage points** and a **p-value of 0.0075**.
- The simulated result is statistically significant, but the lower confidence bound does not exceed the predefined practical threshold of **1 percentage point**.
- The resulting recommendation is therefore to **continue testing before rollout**.

## Dashboard

The analysis is presented through a four-page Looker Studio dashboard covering executive performance, funnel behaviour, product opportunities and experiment evaluation.

### Executive overview

![Executive overview](images/executive_overview.png)

### Conversion funnel

![Conversion funnel](images/conversion_funnel.png)

### Product performance

![Product performance](images/product_performance.png)

### Experiment recommendation

![Experiment recommendation](images/experiment_recommendation.png)

## Experiment design

The historical product analysis identified high-interest YouTube apparel as an experimentation opportunity.

The proposed treatment focuses on reducing uncertainty around product sizing and fit.

| Element | Definition |
|---|---|
| Hypothesis | Clearer size and fit information will reduce uncertainty and increase basket additions |
| Control | Existing product page |
| Treatment | Size-and-fit component with measurements, fit descriptions, model measurements, stock availability and a clearer size-selection prompt |
| Randomisation unit | Anonymous user |
| Primary metric | Product view-to-cart conversion |
| Secondary metrics | Purchase conversion and revenue per user |
| Guardrails | Remove-from-cart rate and page-error rate |
| Significance level | 5% |
| Statistical power | 80% |
| Minimum detectable relative uplift | 10% |
| Minimum practical absolute uplift | 1 percentage point |

The power analysis requires **5,449 users per group**, or **10,898 users in total**.

Based on the historical eligible-user traffic observed during the baseline period, the estimated experiment duration is approximately **84 days**.

This estimate assumes that future eligible traffic remains broadly consistent with the historical baseline.

## Methodology

1. Queried the public GA4 ecommerce export in BigQuery.
2. Explored event coverage, sessions, users and ecommerce activity.
3. Constructed session-level conversion funnel metrics.
4. Investigated tracking quality and defined a reliable tracking period beginning **23 November 2020**.
5. Built ordered same-session product journeys from product view to basket addition and purchase.
6. Analysed conversion behaviour across devices and acquisition channels.
7. Investigated product-level performance and source data quality.
8. Classified merchandise into Google, Android, YouTube and other brands.
9. Compared high-interest YouTube apparel with other products and brands.
10. Selected YouTube apparel as the experimentation opportunity.
11. Created a historical user-level baseline for experiment planning.
12. Calculated sample size from the historical baseline conversion rate.
13. Simulated reproducible control and treatment observations using fixed random seeds.
14. Evaluated the primary metric using a two-sided two-proportion z-test and an unpooled confidence interval.
15. Assessed remove-from-cart, purchase, page-error and revenue guardrails.
16. Built dashboard-ready BigQuery views and experiment tables.
17. Ran final validation checks on funnel ordering, product journeys and experiment data.
18. Presented the findings and experiment decision in Looker Studio.

## Repository structure

```text
google-store-growth-analytics/
├── data/
│   ├── guardrail_statistical_tests.csv
│   ├── guardrail_summary.csv
│   ├── primary_metric_summary.csv
│   └── simulated_youtube_apparel_experiment.csv
│
├── images/
│   ├── conversion_funnel.png
│   ├── executive_overview.png
│   ├── experiment_recommendation.png
│   └── product_performance.png
│
├── notebooks/
│   └── youtube_apparel_ab_test.ipynb
│
├── sql/
│   ├── 01_dataset_overview.sql
│   ├── 02_event_inventory.sql
│   ├── 03_overall_conversion_funnel.sql
│   ├── 04_device_conversion_funnel.sql
│   ├── 05_acquisition_source_funnel.sql
│   ├── 06_product_performance.sql
│   ├── 07_item_data_validation.sql
│   ├── 08_purchase_item_identifiers.sql
│   ├── 09_corrected_product_performance.sql
│   ├── 10_strict_product_funnel.sql
│   ├── 11_target_product_device_comparison.sql
│   ├── 12_target_product_weekly_trend.sql
│   ├── 13_stable_period_product_funnel.sql
│   ├── 14_target_product_metadata.sql
│   ├── 15_youtube_apparel_comparison.sql
│   ├── 16_tee_brand_comparison.sql
│   ├── 17_user_level_experiment_baseline.sql
│   ├── 18_user_level_guardrail_baseline.sql
│   ├── 19_create_session_funnel_view.sql
│   ├── 20_create_dashboard_sessions_view.sql
│   ├── 21_create_dashboard_products_view.sql
│   ├── 22_create_experiment_dashboard_tables.sql
│   ├── 23_validation_checks.sql
│   └── README.md
│
├── .gitignore
├── LICENSE
├── README.md
└── requirements.txt
```

## Data outputs

The `data/` directory contains the reproducible outputs generated from the Python experiment workflow.

### `primary_metric_summary.csv`

Contains the simulated primary view-to-cart metric for the control and treatment groups, including:

- users per group
- cart conversions
- conversion rate

### `guardrail_summary.csv`

Contains simulated group-level guardrail metrics including:

- users
- cart users
- removals
- purchases
- page errors
- revenue
- cart conversion
- remove-from-cart rate
- purchase conversion
- page-error rate
- revenue per user

### `guardrail_statistical_tests.csv`

Contains statistical comparisons for key guardrails, including estimated differences, confidence intervals and p-values.

### `simulated_youtube_apparel_experiment.csv`

Contains the user-level simulated observations used for the reproducible A/B-test analysis.

## Python experiment

The experiment analysis is contained in:

```text
notebooks/youtube_apparel_ab_test.ipynb
```

The notebook covers:

- historical baseline setup
- experiment assumptions
- power analysis
- sample-size calculation
- reproducible simulation
- primary metric evaluation
- confidence interval calculation
- hypothesis testing
- guardrail analysis
- experiment decision logic
- CSV export for dashboard reporting

Fixed random seeds are used so the simulated experiment can be reproduced consistently.

## Reproduce the Python analysis

Create a virtual environment:

```bash
python -m venv .venv
```

Activate the environment.

### macOS / Linux

```bash
source .venv/bin/activate
```

### Windows

```bash
.venv\Scripts\activate
```

Install the required dependencies:

```bash
pip install -r requirements.txt
```

Launch the notebook:

```bash
jupyter notebook notebooks/youtube_apparel_ab_test.ipynb
```

Run all cells from top to bottom.

The notebook reproduces the reported simulated experiment results and exports the CSV files contained in the `data/` directory.

The simulated experiment outputs are also materialised in `sql/22_create_experiment_dashboard_tables.sql` so they can be used directly as Looker Studio dashboard sources.

The Python notebook remains the source of the simulated experiment calculations.

## Data source

The project uses the public BigQuery dataset:

```text
bigquery-public-data.ga4_obfuscated_sample_ecommerce
```

The dataset contains anonymised and obfuscated Google Merchandise Store ecommerce events.

Revenue in the source dataset is reported in **USD**.

Because the GA4 sample is historical, the findings should be interpreted as a product analytics case study rather than an analysis of current Google Merchandise Store performance.

## SQL workflow

The `sql/` directory preserves the complete numbered BigQuery analysis history, from initial exploration to dashboard modelling and validation.

### Dataset and funnel exploration

- `01_dataset_overview.sql`
- `02_event_inventory.sql`
- `03_overall_conversion_funnel.sql`
- `04_device_conversion_funnel.sql`
- `05_acquisition_source_funnel.sql`

These queries establish the dataset structure, event inventory and high-level ecommerce funnel.

### Product analysis and validation

- `06_product_performance.sql`
- `07_item_data_validation.sql`
- `08_purchase_item_identifiers.sql`
- `09_corrected_product_performance.sql`
- `10_strict_product_funnel.sql`

These queries investigate item-level data quality and progressively strengthen product-funnel logic.

### Product opportunity analysis

- `11_target_product_device_comparison.sql`
- `12_target_product_weekly_trend.sql`
- `13_stable_period_product_funnel.sql`
- `14_target_product_metadata.sql`
- `15_youtube_apparel_comparison.sql`
- `16_tee_brand_comparison.sql`

These queries examine the target YouTube apparel opportunity across devices, time periods, metadata and comparable products.

### Experiment baselines

- `17_user_level_experiment_baseline.sql`
- `18_user_level_guardrail_baseline.sql`

These queries calculate the historical user-level baseline used for experiment planning and guardrail evaluation.

### Dashboard modelling

- `19_create_session_funnel_view.sql` — validates and summarises the materialised session-funnel dataset
- `20_create_dashboard_sessions_view.sql` — creates the dashboard-ready session source
- `21_create_dashboard_products_view.sql` — creates the ordered product-journey source
- `22_create_experiment_dashboard_tables.sql` — creates the simulated-experiment dashboard sources

These queries validate the session-funnel dataset and create dashboard-ready session, product and simulated-experiment sources for Looker Studio.

### Validation

- `23_validation_checks.sql`

The final query performs consistency and data-quality checks across the dashboard datasets.

See [`sql/README.md`](sql/README.md) for the complete file-by-file SQL index.

## Validation and data quality

The project includes explicit validation rather than assuming all GA4 events represent clean conversion journeys.

Final checks verify that:

- product-view sessions do not exceed total sessions
- cart sessions do not exceed product-view sessions
- checkout sessions do not exceed cart sessions
- purchase sessions do not exceed checkout sessions
- product cart journeys do not exceed corresponding product views
- product purchase journeys do not exceed corresponding cart journeys
- product revenue is not negative
- the simulated experiment contains the expected control and treatment groups
- experiment sample sizes remain consistent
- simulated dashboard records remain explicitly labelled as simulated

This is particularly important because tracking quality varies across the historical GA4 sample.

## Experiment interpretation

The simulated experiment increased view-to-cart conversion from:

**23.38% → 25.58%**

This represents an estimated:

**+2.20 percentage-point uplift**

with:

- **95% confidence interval:** +0.59 to +3.82 percentage points
- **p-value:** 0.0075
- **significance level:** 0.05

The result is statistically significant.

However, the experiment also uses a predefined **minimum practical absolute uplift of 1 percentage point**.

The lower confidence bound is approximately **+0.59 percentage points**, meaning the confidence interval still contains effects smaller than the predefined practical threshold.

The resulting decision is therefore:

**Continue testing before rollout.**

This decision separates statistical significance from practical product impact.

## Limitations

- The GA4 sample is historical and obfuscated.
- The analysis does not represent current Google Merchandise Store performance.
- Tracking quality varies across the observation period.
- Funnel reporting therefore uses a defined reliable tracking period.
- Ordered same-session product journeys are intentionally stricter than ordinary event totals.
- Brand classification partly relies on product-name rules where source brand information is unavailable.
- The proposed size-and-fit intervention is a product hypothesis derived from the observed conversion opportunity rather than evidence of a confirmed causal mechanism.
- Experiment observations and guardrails are simulated from historical baselines.
- The simulated data does not represent a live experiment conducted by Google.
- The estimated 84-day experiment duration assumes future eligible traffic remains broadly consistent with the historical baseline.
- Purchase and revenue outcomes are relatively rare, so their estimates have greater uncertainty.
- The experiment is powered for the primary view-to-cart metric rather than purchase or revenue.
- Statistical significance alone does not establish commercially meaningful impact.

## Tools

- **BigQuery SQL** — event transformation, funnel construction, product analysis and validation
- **Python** — experiment simulation and statistical analysis
- **pandas** — data manipulation and experiment summaries
- **NumPy** — reproducible simulation
- **SciPy** — statistical calculations
- **statsmodels** — power analysis and hypothesis testing
- **Matplotlib** — analytical visualisation
- **Looker Studio** — dashboarding and decision communication
- **Git** — version control
- **GitHub** — project documentation and portfolio presentation

## Skills demonstrated

This project demonstrates practical experience with:

**SQL · BigQuery · GA4 · Python · pandas · NumPy · SciPy · statsmodels · A/B testing · hypothesis testing · confidence intervals · power analysis · funnel analysis · product analytics · ecommerce analytics · data validation · Looker Studio · data storytelling**

## License

This project is licensed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

## Author

**Miroslaw Mus**

[Portfolio](https://mireqq.vercel.app) · [GitHub](https://github.com/Mireqq) · [LinkedIn](https://www.linkedin.com/in/miroslaw-mus)
