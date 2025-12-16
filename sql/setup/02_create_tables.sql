-- ============================================================================
-- Troon Intelligence Agent - Table Creation
-- ============================================================================
-- Purpose: Create tables for Troon business entities
-- Schema: RAW
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA RAW;

-- ============================================================================
-- 1. Golf Courses
-- ============================================================================
CREATE OR REPLACE TABLE GOLF_COURSES (
    course_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    state VARCHAR(50),
    country VARCHAR(50),
    par INT,
    rating FLOAT,
    slope INT,
    architect VARCHAR(100),
    year_built INT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 2. Members
-- ============================================================================
CREATE OR REPLACE TABLE MEMBERS (
    member_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    join_date DATE,
    membership_tier VARCHAR(50), -- 'Gold', 'Platinum', 'Troon Rewards'
    home_course_id INT REFERENCES GOLF_COURSES(course_id),
    status VARCHAR(20), -- 'Active', 'Inactive'
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 3. Tee Times (Bookings)
-- ============================================================================
CREATE OR REPLACE TABLE TEE_TIMES (
    booking_id VARCHAR(50) PRIMARY KEY,
    course_id INT REFERENCES GOLF_COURSES(course_id),
    member_id INT REFERENCES MEMBERS(member_id),
    play_date DATE,
    booking_time TIME,
    players_count INT,
    price_per_player FLOAT,
    total_revenue FLOAT,
    booking_channel VARCHAR(50), -- 'App', 'Web', 'Phone'
    status VARCHAR(20), -- 'Completed', 'No Show', 'Cancelled'
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 4. Pro Shop Sales
-- ============================================================================
CREATE OR REPLACE TABLE PRO_SHOP_SALES (
    transaction_id VARCHAR(50) PRIMARY KEY,
    course_id INT REFERENCES GOLF_COURSES(course_id),
    member_id INT REFERENCES MEMBERS(member_id),
    sale_date TIMESTAMP_NTZ,
    item_category VARCHAR(50), -- 'Apparel', 'Equipment', 'Accessories', 'Balls'
    item_name VARCHAR(100),
    quantity INT,
    unit_price FLOAT,
    total_amount FLOAT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 5. Course Reviews (Unstructured Text)
-- ============================================================================
CREATE OR REPLACE TABLE COURSE_REVIEWS (
    review_id VARCHAR(50) PRIMARY KEY,
    course_id INT REFERENCES GOLF_COURSES(course_id),
    member_id INT REFERENCES MEMBERS(member_id),
    review_date DATE,
    rating INT,
    review_text VARCHAR(16777216), -- Max length for TEXT
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 6. Maintenance Logs (Unstructured Text)
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_LOGS (
    log_id VARCHAR(50) PRIMARY KEY,
    course_id INT REFERENCES GOLF_COURSES(course_id),
    log_date DATE,
    maintenance_type VARCHAR(100), -- 'Aeration', 'Mowing', 'Irrigation Repair'
    description VARCHAR(16777216),
    technician_name VARCHAR(100),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 7. Club Policies (Unstructured Text for Cortex Search)
-- ============================================================================
CREATE OR REPLACE TABLE CLUB_POLICIES (
    policy_id VARCHAR(50) PRIMARY KEY,
    title VARCHAR(200),
    category VARCHAR(100), -- 'Dress Code', 'Cancellation', 'Pace of Play'
    last_updated DATE,
    content VARCHAR(16777216),
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 8. RealFood Projects (Structured Data)
-- ============================================================================
CREATE OR REPLACE TABLE REALFOOD_PROJECTS (
    project_id VARCHAR(50) PRIMARY KEY,
    project_name VARCHAR(150),
    client_name VARCHAR(150),
    sector VARCHAR(100), -- 'Hotels & Resorts', 'Restaurants & Bars', 'Education', etc.
    service_type VARCHAR(100), -- 'Design', 'Strategy', 'Operations'
    status VARCHAR(50), -- 'Active', 'Completed', 'Planning'
    completion_date DATE,
    project_budget FLOAT,
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- 9. RealFood Services (Unstructured Text for Cortex Search)
-- ============================================================================
CREATE OR REPLACE TABLE REALFOOD_SERVICES (
    service_id VARCHAR(50) PRIMARY KEY,
    service_name VARCHAR(150),
    category VARCHAR(100), -- 'Foodservice Design', 'Interior Design', 'Strategy', 'Branding'
    description VARCHAR(16777216), -- Detailed service description
    created_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Verification
-- ============================================================================
SELECT 'Tables created successfully' AS STATUS;
SHOW TABLES IN SCHEMA RAW;
