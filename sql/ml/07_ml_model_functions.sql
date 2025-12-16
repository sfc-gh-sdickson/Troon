-- ============================================================================
-- Troon ML Model Functions
-- ============================================================================
-- Creates SQL UDF wrappers for ML model inference
-- Designed to be called by Cortex Agent
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA ML_MODELS;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Function 1: Predict Churn Risk (Bulk Analysis)
-- ============================================================================
-- Returns: Summary of churn risk for members, optionally filtered by tier
CREATE OR REPLACE FUNCTION PREDICT_CHURN_RISK(tier_filter VARCHAR)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Members Analyzed: ' || COUNT(*) || 
        ', Low Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 0 THEN 1 ELSE 0 END) ||
        ', Medium Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 1 THEN 1 ELSE 0 END) ||
        ', High Risk: ' || SUM(CASE WHEN pred:PREDICTED_RISK::INT = 2 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            CHURN_RISK_PREDICTOR!PREDICT(
                tenure_months, total_shop_spend, rounds_played
            ) as pred
        FROM TROON_INTELLIGENCE.ANALYTICS.V_CHURN_RISK_FEATURES v
        JOIN TROON_INTELLIGENCE.RAW.MEMBERS m ON v.member_id = m.member_id
        WHERE tier_filter IS NULL OR m.membership_tier = tier_filter
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 2: Predict No-Show Probability (Bulk Analysis)
-- ============================================================================
-- Returns: Summary of no-show risk for upcoming bookings
CREATE OR REPLACE FUNCTION PREDICT_NO_SHOW_RISK(days_ahead INT)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Total Bookings Analyzed: ' || COUNT(*) || 
        ', Predicted No-Shows: ' || SUM(CASE WHEN pred:NO_SHOW_LABEL::INT = 1 THEN 1 ELSE 0 END) ||
        ', Expected Attendance: ' || SUM(CASE WHEN pred:NO_SHOW_LABEL::INT = 0 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            NO_SHOW_PREDICTOR!PREDICT(
                lead_time_days, players_count, price, hour_of_day
            ) as pred
        FROM TROON_INTELLIGENCE.ANALYTICS.V_NO_SHOW_FEATURES
        -- Simulate looking at future bookings (using existing data for demo)
        LIMIT 100
    )
$$;

-- ============================================================================
-- Function 3: Identify Upgrade Candidates
-- ============================================================================
-- Returns: Count of members identified as upgrade candidates
CREATE OR REPLACE FUNCTION IDENTIFY_UPGRADE_CANDIDATES(min_spend_threshold FLOAT)
RETURNS VARCHAR
AS
$$
    SELECT 
        'Members Analyzed: ' || COUNT(*) ||
        ', Recommended for Upgrade: ' || SUM(CASE WHEN pred:UPGRADE_CANDIDATE_LABEL::INT = 1 THEN 1 ELSE 0 END)
    FROM (
        SELECT 
            UPGRADE_CANDIDATE_PREDICTOR!PREDICT(
                total_greens_fees, total_shop_spend, rounds_played
            ) as pred
        FROM TROON_INTELLIGENCE.ANALYTICS.V_UPGRADE_FEATURES
        WHERE total_shop_spend > COALESCE(min_spend_threshold, 0)
        LIMIT 100
    )
$$;

SELECT 'ML Model Functions created successfully' AS STATUS;
SHOW USER FUNCTIONS IN SCHEMA ML_MODELS;
