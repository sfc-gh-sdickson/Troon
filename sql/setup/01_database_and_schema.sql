-- ============================================================================
-- Troon Intelligence Agent - Database and Schema Setup
-- ============================================================================
-- Purpose: Create database, schemas, and warehouse for Troon intelligence platform
-- ============================================================================

-- ============================================================================
-- Step 1: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS TROON_INTELLIGENCE
  COMMENT = 'Troon Golf management intelligence platform';

USE DATABASE TROON_INTELLIGENCE;

-- ============================================================================
-- Step 2: Create Schemas
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS RAW
  COMMENT = 'Raw data tables for courses, members, tee times, and sales';

CREATE SCHEMA IF NOT EXISTS ANALYTICS
  COMMENT = 'Analytical views, semantic views, and feature engineering';

CREATE SCHEMA IF NOT EXISTS ML_MODELS
  COMMENT = 'ML model registry and prediction functions';

-- ============================================================================
-- Step 3: Create Warehouse
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS TROON_WH
  WITH WAREHOUSE_SIZE = 'X-SMALL'
  AUTO_SUSPEND = 300
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = FALSE
  COMMENT = 'Warehouse for Troon analytics and operations';

USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Step 4: Grant Permissions
-- ============================================================================
-- Note: Adjust role as per environment (e.g., ACCOUNTADMIN or SYSADMIN)
GRANT USAGE ON DATABASE TROON_INTELLIGENCE TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA RAW TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ANALYTICS TO ROLE SYSADMIN;
GRANT USAGE ON SCHEMA ML_MODELS TO ROLE SYSADMIN;
GRANT USAGE ON WAREHOUSE TROON_WH TO ROLE SYSADMIN;

-- ============================================================================
-- Confirmation
-- ============================================================================
SELECT 'Troon database, schemas, and warehouse created successfully' AS STATUS;

SHOW DATABASES LIKE 'TROON%';
SHOW SCHEMAS IN DATABASE TROON_INTELLIGENCE;
SHOW WAREHOUSES LIKE 'TROON%';

