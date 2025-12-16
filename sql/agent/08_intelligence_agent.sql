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
    response: "You are a helpful golf management and hospitality intelligence assistant for Troon and RealFood. Provide clear, accurate answers about course performance, member engagement, retail sales, and hospitality projects. When using ML predictions, explain the insights clearly. Always cite data sources."
    orchestration: "For course performance, revenue, and bookings use CourseAnalyst. For member stats, engagement, and spending use MemberAnalyst. For pro shop sales and merchandise use ProShopAnalyst. For RealFood projects, clients, and budgets use RealFoodProjectAnalyst. For course reviews use ReviewSearch. For maintenance logs use MaintenanceSearch. For club policies use PolicySearch. For RealFood services and capabilities use RealFoodServiceSearch. For ML predictions use the appropriate prediction function."
    system: "You are an expert golf operations and hospitality strategy analyst. You help optimize tee sheets, improve member retention, analyze retail performance, and track hospitality design projects."
    sample_questions:
      # Simple Questions (Data Retrieval)
      - question: "What was the total revenue for Troon North Golf Club last month?"
        answer: "I'll use CourseAnalyst to sum total_revenue grouped by course_name for the last month."
      - question: "How many active Platinum members do we currently have?"
        answer: "I'll use MemberAnalyst to count members where membership_tier is Platinum and status is Active."
      - question: "List the top 5 selling items in the Pro Shop by revenue."
        answer: "I'll use ProShopAnalyst to sum total_sales_amount grouped by item_name, ordered by revenue descending, limited to 5."
      - question: "What is the cancellation policy for rain?"
        answer: "I'll use PolicySearch to find club policies related to 'cancellation' and 'rain'."
      - question: "Show me the most recent maintenance log for Kapalua."
        answer: "I'll use MaintenanceSearch to find the most recent maintenance log entries for 'Kapalua'."
        
      # Complex Questions (Analysis)
      - question: "Which golf course has the highest average revenue per booking on weekends?"
        answer: "I'll use CourseAnalyst to calculate avg_revenue_per_booking grouped by course_name, filtering for weekend days."
      - question: "What is the average tenure of members who spent more than $500 in the pro shop last year?"
        answer: "I'll use MemberAnalyst to calculate average tenure_years for members where total_merchandise_spend > 500."
      - question: "Compare the total revenue from 'Apparel' vs 'Equipment' sales for the last quarter."
        answer: "I'll use ProShopAnalyst to sum total_sales_amount grouped by item_category for 'Apparel' and 'Equipment' in the last quarter."
      - question: "Summarize the main complaints from member reviews regarding pace of play."
        answer: "I'll use ReviewSearch to find reviews containing 'pace of play' and summarize the findings."
      - question: "Identify courses where maintenance logs mention 'irrigation' issues."
        answer: "I'll use MaintenanceSearch to find logs mentioning 'irrigation' and list the associated courses."
        
      # Machine Learning Questions (Predictions)
      - question: "Predict the churn risk for all our 'Troon Rewards' tier members."
        answer: "I'll use PredictChurn with tier_filter='Troon Rewards' to analyze risk for those members."
      - question: "How many members are candidates for an upgrade based on a $1000 spend threshold?"
        answer: "I'll use IdentifyUpgrades with min_spend_threshold=1000."
      - question: "What is the risk of no-shows for bookings in the next 7 days?"
        answer: "I'll use PredictNoShow with days_ahead=7."
      - question: "Which membership tier has the highest proportion of high-risk members?"
        answer: "I'll use PredictChurn with tier_filter=NULL to analyze all tiers and identify the one with the highest high-risk count."
      - question: "Are there any high-value members at risk of leaving?"
        answer: "I'll use PredictChurn to identify high-risk members and MemberAnalyst to check their spending value."

      # RealFood Hospitality Questions
      - question: "List all active RealFood projects in the Hotels & Resorts sector."
        answer: "I'll use RealFoodProjectAnalyst to list projects where status is 'Active' and sector is 'Hotels & Resorts'."
      - question: "What RealFood services are available for kitchen design?"
        answer: "I'll use RealFoodServiceSearch to find services related to 'kitchen design' and 'foodservice facility design'."
      - question: "What is the total budget for completed Strategy projects?"
        answer: "I'll use RealFoodProjectAnalyst to sum project_budget where status is 'Completed' and service_type includes 'Strategy'."

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

    - tool_spec:
        type: "cortex_analyst_text_to_sql"
        name: "RealFoodProjectAnalyst"
        description: "Analyzes RealFood Hospitality projects, budgets, clients, and sectors. Use for questions about hospitality design projects, strategy consulting, and F&B operations."

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

    - tool_spec:
        type: "cortex_search"
        name: "RealFoodServiceSearch"
        description: "Searches RealFood Hospitality service descriptions and capabilities. Use when users ask about available consulting services, design capabilities, or operational support."

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

    RealFoodProjectAnalyst:
      semantic_view: "TROON_INTELLIGENCE.ANALYTICS.SV_REALFOOD_PROJECTS"

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

    RealFoodServiceSearch:
      name: "TROON_INTELLIGENCE.RAW.REALFOOD_SERVICES_SEARCH"
      max_results: "5"
      title_column: "service_name"
      id_column: "service_id"

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
