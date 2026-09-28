CREATE OR REPLACE VIEW
    `grand-magpie-446717-v3.google_store_analytics.dashboard_sessions`
AS

SELECT
    session_id,
    user_pseudo_id,
    session_date,
    session_start,
    session_end,
    session_duration_seconds,

    COALESCE(
        device_category,
        'Unknown'
    ) AS device_category,

    COALESCE(
        country,
        'Unknown'
    ) AS country,

    COALESCE(
        first_user_source,
        'Unknown'
    ) AS first_user_source,

    COALESCE(
        first_user_medium,
        'Unknown'
    ) AS first_user_medium,

    CASE
        WHEN first_user_source = '(direct)'
            AND first_user_medium = '(none)'
            THEN 'Direct'

        WHEN first_user_medium = 'organic'
            THEN 'Organic Search'

        WHEN first_user_medium = 'cpc'
            THEN 'Paid Search'

        WHEN first_user_medium = 'referral'
            THEN 'Referral'

        WHEN first_user_source IS NULL
            OR first_user_medium IS NULL
            THEN 'Unknown'

        ELSE 'Other'
    END AS first_user_channel,

    IF(
        is_new_user = 1,
        'New user',
        'Returning user'
    ) AS user_type,

    CASE
        WHEN session_date < DATE '2020-11-23'
            THEN 'Unreliable cart tracking'
        ELSE 'Stable cart tracking'
    END AS cart_tracking_status,

    IF(
        session_date >= DATE '2020-11-23',
        1,
        0
    ) AS eligible_for_cart_analysis,

    event_count,
    page_views,
    viewed_product,
    added_to_cart,
    began_checkout,
    purchased,
    revenue

FROM
    `grand-magpie-446717-v3.google_store_analytics.session_funnel`;