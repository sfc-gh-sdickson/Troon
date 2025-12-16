-- ============================================================================
-- Troon Intelligence Agent - Agent Configuration
-- ============================================================================
-- Purpose: Create Snowflake Intelligence Agent with semantic views and ML tools
-- Agent: TROON_INTELLIGENCE_AGENT
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Create Cortex Agent
-- ============================================================================
CREATE OR REPLACE AGENT TROON_INTELLIGENCE_AGENT
  COMMENT = 'Troon Golf intelligence agent with ML predictions and semantic search'
  PROFILE = '{"display_name": "Troon Intelligence Assistant", "avatar": "troon-icon.png", "color": "green"}'
  FROM SPECIFICATION
  $$
  models:
    orchestration: auto

  orchestration:
    budget:
      seconds: 60
      tokens: 32000

  instructions:
    response: "You are a helpful golf management intelligence assistant for Troon. Provide clear, accurate answers about course performance, member engagement, and retail sales. When using ML predictions, explain the insights clearly. Always cite data sources."
    orchestration: "For course performance, revenue, and bookings use CourseAnalyst. For member stats, engagement, and spending use MemberAnalyst. For pro shop sales and merchandise use ProShopAnalyst. For course reviews use ReviewSearch. For maintenance logs use MaintenanceSearch. For club policies use PolicySearch. For ML predictions use the appropriate prediction function."
    system: "You are an expert golf operations analyst. You help optimize tee sheets, improve member retention, and analyze retail performance."
    sample_questions:
      - question: "Which course generated the most revenue last month?"
        answer: "I'll use CourseAnalyst to sum total_revenue grouped by course_name for the last month."
      - question: "How many Platinum members do we have?"
        answer: "I'll use MemberAnalyst to count members where membership_tier is Platinum."
      - question: "What are members saying about the greens at Troon North?"
        answer: "I'll use ReviewSearch to find reviews for Troon North mentioning 'greens'."
      - question: "Predict the churn risk for our Gold members"
        answer: "I'll use PredictChurn to analyze risk for 'Gold' tier members."
      - question: "Show me the maintenance logs for irrigation repairs"
        answer: "I'll use MaintenanceSearch to find logs with maintenance_type 'Irrigation'."

  tools:
    # Semantic Views for Cortex Analyst
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "CourseAnalyst"
        description: "Analyzes golf course performance, revenue, bookings, and utilization. Use for questions about tee times, revenue per round, and course activity."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "MemberAnalyst"
        description: "Analyzes member demographics, tenure, spending habits, and play frequency. Use for questions about membership tiers, retention, and member value."
    
    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "ProShopAnalyst"
        description: "Analyzes pro shop retail sales, inventory categories, and transaction values. Use for questions about merchandise, equipment sales, and shop revenue."

    # Cortex Search Services
    - tool_spec:
        type: "cortex_search"
        name: "ReviewSearch"
        description: "Searches unstructured member reviews. Use when users ask about player feedback, course conditions sentiment, or ratings."

    - tool_spec:
        type: "cortex_search"
        name: "MaintenanceSearch"
        description: "Searches course maintenance logs. Use when users ask about agronomy, repairs, mowing, or course work history."

    - tool_spec:
        type: "cortex_search"
        name: "PolicySearch"
        description: "Searches club policies and SOPs. Use when users ask about dress codes, cancellation policies, or rules."

    # ML Model Procedures
    - tool_spec:
        type: "generic"
        name: "PredictChurn"
        description: "Predicts churn risk for members. Returns risk distribution. Input: tier_filter (Gold, Platinum, Troon Rewards) or NULL."
        input_schema:
          type: "object"
          properties:
            tier_filter:
              type: "string"
              description: "Filter by membership tier or NULL for all"
          required: []

    - tool_spec:
        type: "generic"
        name: "PredictNoShow"
        description: "Predicts no-show risk for bookings. Returns summary of expected no-shows."
        input_schema:
          type: "object"
          properties:
            days_ahead:
              type: "integer"
              description: "Number of days ahead to analyze"
          required: []

    - tool_spec:
        type: "generic"
        name: "IdentifyUpgrades"
        description: "Identifies members suitable for tier upgrades based on spending. Returns count of candidates."
        input_schema:
          type: "object"
          properties:
            min_spend_threshold:
              type: "number"
              description: "Minimum spend to consider for upgrade"
          required: []

  tool_resources:
    # Semantic View Resources
    CourseAnalyst:
      semantic_view: "TROON_INTELLIGENCE.ANALYTICS.SV_COURSE_PERFORMANCE"
    
    MemberAnalyst:
      semantic_view: "TROON_INTELLIGENCE.ANALYTICS.SV_MEMBER_ANALYTICS"
    
    ProShopAnalyst:
      semantic_view: "TROON_INTELLIGENCE.ANALYTICS.SV_PRO_SHOP_INSIGHTS"

    # Cortex Search Resources
    ReviewSearch:
      name: "TROON_INTELLIGENCE.RAW.COURSE_REVIEWS_SEARCH"
      max_results: "10"
      title_column: "review_text"
      id_column: "review_id"

    MaintenanceSearch:
      name: "TROON_INTELLIGENCE.RAW.MAINTENANCE_LOGS_SEARCH"
      max_results: "10"
      title_column: "description"
      id_column: "log_id"

    PolicySearch:
      name: "TROON_INTELLIGENCE.RAW.CLUB_POLICIES_SEARCH"
      max_results: "5"
      title_column: "title"
      id_column: "policy_id"

    # ML Model Procedure Resources
    PredictChurn:
      type: "function"
      identifier: "TROON_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "TROON_WH"

    PredictNoShow:
      type: "function"
      identifier: "TROON_INTELLIGENCE.ML_MODELS.PREDICT_NO_SHOW_RISK"
      execution_environment:
        type: "warehouse"
        warehouse: "TROON_WH"

    IdentifyUpgrades:
      type: "function"
      identifier: "TROON_INTELLIGENCE.ML_MODELS.IDENTIFY_UPGRADE_CANDIDATES"
      execution_environment:
        type: "warehouse"
        warehouse: "TROON_WH"
  $$;

-- ============================================================================
-- Permissions
-- ============================================================================
GRANT USAGE ON AGENT TROON_INTELLIGENCE_AGENT TO ROLE SYSADMIN;

SELECT 'Troon Intelligence Agent created successfully' AS STATUS;
SHOW AGENTS IN SCHEMA ANALYTICS;

