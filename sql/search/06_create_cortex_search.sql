-- ============================================================================
-- Troon Intelligence Agent - Cortex Search Services
-- ============================================================================
-- Purpose: Enable semantic search over unstructured reviews, logs, policies, and services
-- Tables: COURSE_REVIEWS, MAINTENANCE_LOGS, CLUB_POLICIES, REALFOOD_SERVICES
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Service 1: Course Reviews Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE COURSE_REVIEWS_SEARCH
  ON review_text
  ATTRIBUTES rating, course_id, review_date
  WAREHOUSE = TROON_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search member reviews to analyze sentiment and feedback'
AS
  SELECT
    review_id,
    review_text,
    rating,
    course_id,
    review_date,
    created_at
  FROM COURSE_REVIEWS;

-- ============================================================================
-- Service 2: Maintenance Logs Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MAINTENANCE_LOGS_SEARCH
  ON description
  ATTRIBUTES maintenance_type, course_id, log_date
  WAREHOUSE = TROON_WH
  TARGET_LAG = '1 hour'
  COMMENT = 'Search agronomy and maintenance logs for operational insights'
AS
  SELECT
    log_id,
    description,
    maintenance_type,
    course_id,
    log_date,
    technician_name,
    created_at
  FROM MAINTENANCE_LOGS;

-- ============================================================================
-- Service 3: Club Policies Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE CLUB_POLICIES_SEARCH
  ON content
  ATTRIBUTES category, title, last_updated
  WAREHOUSE = TROON_WH
  TARGET_LAG = '1 day'
  COMMENT = 'Search club policies and standard operating procedures'
AS
  SELECT
    policy_id,
    content,
    title,
    category,
    last_updated,
    created_at
  FROM CLUB_POLICIES;

-- ============================================================================
-- Service 4: RealFood Services Search
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE REALFOOD_SERVICES_SEARCH
  ON description
  ATTRIBUTES category, service_name
  WAREHOUSE = TROON_WH
  TARGET_LAG = '1 day'
  COMMENT = 'Search RealFood Hospitality services and capabilities'
AS
  SELECT
    service_id,
    description,
    service_name,
    category,
    created_at
  FROM REALFOOD_SERVICES;

-- ============================================================================
-- Grant Permissions
-- ============================================================================
GRANT USAGE ON CORTEX SEARCH SERVICE COURSE_REVIEWS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE MAINTENANCE_LOGS_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE CLUB_POLICIES_SEARCH TO ROLE SYSADMIN;
GRANT USAGE ON CORTEX SEARCH SERVICE REALFOOD_SERVICES_SEARCH TO ROLE SYSADMIN;

SELECT 'Cortex Search Services Created Successfully' AS STATUS;
SHOW CORTEX SEARCH SERVICES IN SCHEMA RAW;
