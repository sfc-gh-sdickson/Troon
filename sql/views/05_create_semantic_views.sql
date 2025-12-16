-- ============================================================================
-- Troon Intelligence Agent - Semantic Views
-- ============================================================================
-- Purpose: Semantic views for Cortex Analyst text-to-SQL capabilities
-- Syntax: VERIFIED against Snowflake documentation
-- Column names: VERIFIED against table definitions
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA ANALYTICS;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Semantic View 1: Course Performance Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_COURSE_PERFORMANCE
  TABLES (
    courses AS RAW.GOLF_COURSES
      PRIMARY KEY (course_id),
    bookings AS RAW.TEE_TIMES
      PRIMARY KEY (booking_id)
  )
  RELATIONSHIPS (
    bookings(course_id) REFERENCES courses(course_id)
  )
  DIMENSIONS (
    courses.course_name AS courses.name,
    courses.city AS courses.city,
    courses.state AS courses.state,
    courses.country AS courses.country,
    courses.architect AS courses.architect,
    bookings.status AS bookings.status,
    bookings.channel AS bookings.booking_channel,
    bookings.play_month AS DATE_TRUNC('month', bookings.play_date),
    bookings.play_year AS DATE_TRUNC('year', bookings.play_date)
  )
  METRICS (
    bookings.total_bookings AS COUNT(DISTINCT bookings.booking_id),
    bookings.total_revenue AS SUM(bookings.total_revenue),
    bookings.total_players AS SUM(bookings.players_count),
    bookings.completed_bookings AS COUNT_IF(bookings.status = 'Completed'),
    bookings.cancelled_bookings AS COUNT_IF(bookings.status = 'Cancelled'),
    bookings.no_show_bookings AS COUNT_IF(bookings.status = 'No Show')
  )
  COMMENT = 'Semantic view for golf course performance, revenue, and booking trends';

-- ============================================================================
-- Semantic View 2: Member Engagement Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MEMBER_ANALYTICS
  TABLES (
    members AS RAW.MEMBERS
      PRIMARY KEY (member_id),
    bookings AS RAW.TEE_TIMES
      PRIMARY KEY (booking_id),
    sales AS RAW.PRO_SHOP_SALES
      PRIMARY KEY (transaction_id)
  )
  RELATIONSHIPS (
    bookings(member_id) REFERENCES members(member_id),
    sales(member_id) REFERENCES members(member_id)
  )
  DIMENSIONS (
    members.membership_tier AS members.membership_tier,
    members.status AS members.status,
    members.join_year AS DATE_TRUNC('year', members.join_date),
    members.tenure_years AS DATEDIFF(year, members.join_date, CURRENT_DATE())
  )
  METRICS (
    members.total_members AS COUNT(DISTINCT members.member_id),
    bookings.total_rounds_played AS COUNT(DISTINCT bookings.booking_id),
    bookings.total_greens_fees AS SUM(bookings.total_revenue),
    sales.total_merchandise_spend AS SUM(sales.total_amount),
    sales.total_transactions AS COUNT(DISTINCT sales.transaction_id)
  )
  COMMENT = 'Semantic view for member engagement, spending, and play frequency';

-- ============================================================================
-- Semantic View 3: Pro Shop Sales Insights
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_PRO_SHOP_INSIGHTS
  TABLES (
    sales AS RAW.PRO_SHOP_SALES
      PRIMARY KEY (transaction_id),
    courses AS RAW.GOLF_COURSES
      PRIMARY KEY (course_id)
  )
  RELATIONSHIPS (
    sales(course_id) REFERENCES courses(course_id)
  )
  DIMENSIONS (
    courses.course_name AS courses.name,
    sales.item_category AS sales.item_category,
    sales.item_name AS sales.item_name,
    sales.sale_month AS DATE_TRUNC('month', sales.sale_date),
    sales.sale_day AS DATE_TRUNC('day', sales.sale_date)
  )
  METRICS (
    sales.total_sales_amount AS SUM(sales.total_amount),
    sales.total_items_sold AS SUM(sales.quantity),
    sales.avg_transaction_value AS AVG(sales.total_amount),
    sales.transaction_count AS COUNT(DISTINCT sales.transaction_id)
  )
  COMMENT = 'Semantic view for retail performance, merchandise trends, and inventory analysis';

-- ============================================================================
-- Semantic View 4: RealFood Project Analytics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_REALFOOD_PROJECTS
  TABLES (
    projects AS RAW.REALFOOD_PROJECTS
      PRIMARY KEY (project_id)
  )
  DIMENSIONS (
    projects.project_name AS projects.project_name,
    projects.client_name AS projects.client_name,
    projects.sector AS projects.sector,
    projects.service_type AS projects.service_type,
    projects.status AS projects.status,
    projects.completion_year AS DATE_TRUNC('year', projects.completion_date)
  )
  METRICS (
    projects.total_projects AS COUNT(DISTINCT projects.project_id),
    projects.total_budget AS SUM(projects.project_budget),
    projects.avg_budget AS AVG(projects.project_budget),
    projects.active_projects AS COUNT_IF(projects.status = 'Active'),
    projects.completed_projects AS COUNT_IF(projects.status = 'Completed')
  )
  COMMENT = 'Semantic view for RealFood Hospitality projects, budgets, and clients';

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'Troon semantic views created successfully' AS STATUS;
SHOW SEMANTIC VIEWS IN SCHEMA ANALYTICS;
