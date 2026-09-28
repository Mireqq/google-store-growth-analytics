SELECT
    COUNT(*) AS total_sessions,
    COUNT(DISTINCT user_pseudo_id) AS unique_users,
    COUNTIF(viewed_product = 1) AS product_view_sessions,
    COUNTIF(added_to_cart = 1) AS cart_sessions,
    COUNTIF(began_checkout = 1) AS checkout_sessions,
    COUNTIF(purchased = 1) AS purchase_sessions,
    ROUND(SUM(revenue), 2) AS total_revenue
FROM
    `grand-magpie-446717-v3.google_store_analytics.session_funnel`;