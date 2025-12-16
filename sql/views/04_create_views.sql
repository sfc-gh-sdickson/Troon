-- ============================================================================
-- Troon Intelligence Agent - Feature Engineering for ML
-- ============================================================================
-- Purpose: Create views for ML model training
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Feature View 1: Churn Risk Features
-- ============================================================================
CREATE OR REPLACE VIEW V_CHURN_RISK_FEATURES AS
SELECT
    m.member_id,
    DATEDIFF(month, m.join_date, CURRENT_DATE())::FLOAT AS tenure_months,
    COALESCE(SUM(s.total_amount), 0)::FLOAT AS total_shop_spend,
    COUNT(DISTINCT t.booking_id)::FLOAT AS rounds_played,
    -- Synthetic Label: 0=Low Risk, 1=Medium Risk, 2=High Risk
    -- Logic: High spend/play = Low Risk
    CASE
        WHEN COUNT(DISTINCT t.booking_id) > 5 AND SUM(s.total_amount) > 500 THEN 0
        WHEN COUNT(DISTINCT t.booking_id) > 2 THEN 1
        ELSE 2
    END AS churn_risk_label
FROM RAW.MEMBERS m
LEFT JOIN RAW.PRO_SHOP_SALES s ON m.member_id = s.member_id
LEFT JOIN RAW.TEE_TIMES t ON m.member_id = t.member_id
GROUP BY m.member_id, m.join_date;

-- ============================================================================
-- Feature View 2: No-Show Prediction Features
-- ============================================================================
CREATE OR REPLACE VIEW V_NO_SHOW_FEATURES AS
SELECT
    booking_id,
    DATEDIFF(day, created_at, play_date)::FLOAT AS lead_time_days,
    players_count::FLOAT AS players_count,
    price_per_player::FLOAT AS price,
    DATE_PART(hour, booking_time)::FLOAT AS hour_of_day,
    -- Label: 1 = No Show, 0 = Completed/Other
    CASE WHEN status = 'No Show' THEN 1 ELSE 0 END AS no_show_label
FROM RAW.TEE_TIMES
WHERE status IN ('Completed', 'No Show');

-- ============================================================================
-- Feature View 3: Membership Upgrade Likelihood Features
-- ============================================================================
CREATE OR REPLACE VIEW V_UPGRADE_FEATURES AS
SELECT
    m.member_id,
    COALESCE(SUM(t.total_revenue), 0)::FLOAT AS total_greens_fees,
    COALESCE(SUM(s.total_amount), 0)::FLOAT AS total_shop_spend,
    COUNT(DISTINCT t.booking_id)::FLOAT AS rounds_played,
    -- Label: 1 = Good Candidate (High Value), 0 = Standard
    CASE
        WHEN (SUM(t.total_revenue) + SUM(s.total_amount)) > 1000 THEN 1
        ELSE 0
    END AS upgrade_candidate_label
FROM RAW.MEMBERS m
LEFT JOIN RAW.TEE_TIMES t ON m.member_id = t.member_id
LEFT JOIN RAW.PRO_SHOP_SALES s ON m.member_id = s.member_id
GROUP BY m.member_id;

SELECT 'Feature views created successfully' AS STATUS;
SHOW VIEWS IN SCHEMA ANALYTICS;

