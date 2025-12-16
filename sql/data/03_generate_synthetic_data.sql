-- ============================================================================
-- Troon Intelligence Agent - Synthetic Data Generation
-- ============================================================================
-- Purpose: Generate realistic synthetic data for Troon platform
-- Data Volume: Courses (10), Members (1000), Tee Times (5000), Sales (5000)
-- RealFood Data: Projects (50), Services (10)
-- ============================================================================

USE DATABASE TROON_INTELLIGENCE;
USE SCHEMA RAW;
USE WAREHOUSE TROON_WH;

-- ============================================================================
-- Clear existing data
-- ============================================================================
TRUNCATE TABLE IF EXISTS REALFOOD_SERVICES;
TRUNCATE TABLE IF EXISTS REALFOOD_PROJECTS;
TRUNCATE TABLE IF EXISTS CLUB_POLICIES;
TRUNCATE TABLE IF EXISTS MAINTENANCE_LOGS;
TRUNCATE TABLE IF EXISTS COURSE_REVIEWS;
TRUNCATE TABLE IF EXISTS PRO_SHOP_SALES;
TRUNCATE TABLE IF EXISTS TEE_TIMES;
TRUNCATE TABLE IF EXISTS MEMBERS;
TRUNCATE TABLE IF EXISTS GOLF_COURSES;

-- ============================================================================
-- 1. Golf Courses (10 specific high-profile courses)
-- ============================================================================
INSERT INTO GOLF_COURSES (course_id, name, city, state, country, par, rating, slope, architect, year_built)
SELECT 
    value:id::INT,
    value:name::STRING,
    value:city::STRING,
    value:state::STRING,
    value:country::STRING,
    value:par::INT,
    value:rating::FLOAT,
    value:slope::INT,
    value:architect::STRING,
    value:year::INT
FROM LATERAL FLATTEN(INPUT => PARSE_JSON('[
    {"id": 1, "name": "Troon North Golf Club - Monument", "city": "Scottsdale", "state": "AZ", "country": "USA", "par": 72, "rating": 73.5, "slope": 145, "architect": "Tom Weiskopf", "year": 1990},
    {"id": 2, "name": "Kapalua - Plantation Course", "city": "Lahaina", "state": "HI", "country": "USA", "par": 73, "rating": 75.2, "slope": 140, "architect": "Coore & Crenshaw", "year": 1991},
    {"id": 3, "name": "Pronghorn - Nicklaus Course", "city": "Bend", "state": "OR", "country": "USA", "par": 72, "rating": 74.8, "slope": 142, "architect": "Jack Nicklaus", "year": 2004},
    {"id": 4, "name": "The Grove", "city": "London", "state": "Hertfordshire", "country": "UK", "par": 72, "rating": 72.9, "slope": 138, "architect": "Kyle Phillips", "year": 2003},
    {"id": 5, "name": "Yas Links Abu Dhabi", "city": "Abu Dhabi", "state": "AD", "country": "UAE", "par": 72, "rating": 76.1, "slope": 148, "architect": "Kyle Phillips", "year": 2010},
    {"id": 6, "name": "Quintero Golf Club", "city": "Peoria", "state": "AZ", "country": "USA", "par": 72, "rating": 74.2, "slope": 146, "architect": "Rees Jones", "year": 2000},
    {"id": 7, "name": "Princeville Makai Golf Club", "city": "Princeville", "state": "HI", "country": "USA", "par": 72, "rating": 73.8, "slope": 135, "architect": "Robert Trent Jones Jr", "year": 1971},
    {"id": 8, "name": "Classic Club", "city": "Palm Desert", "state": "CA", "country": "USA", "par": 72, "rating": 74.5, "slope": 142, "architect": "Arnold Palmer", "year": 2006},
    {"id": 9, "name": "Tiburón Golf Club - Gold", "city": "Naples", "state": "FL", "country": "USA", "par": 72, "rating": 74.0, "slope": 137, "architect": "Greg Norman", "year": 1998},
    {"id": 10, "name": "Indian Wells Golf Resort - Players", "city": "Indian Wells", "state": "CA", "country": "USA", "par": 72, "rating": 73.1, "slope": 139, "architect": "John Fought", "year": 2007}
]'));

-- ============================================================================
-- 2. Members (1000 rows)
-- ============================================================================
INSERT INTO MEMBERS
SELECT
    SEQ4() + 1000 AS member_id,
    CASE MOD(SEQ4(), 20)
        WHEN 0 THEN 'James' WHEN 1 THEN 'John' WHEN 2 THEN 'Robert' WHEN 3 THEN 'Michael' WHEN 4 THEN 'William'
        WHEN 5 THEN 'David' WHEN 6 THEN 'Richard' WHEN 7 THEN 'Joseph' WHEN 8 THEN 'Thomas' WHEN 9 THEN 'Charles'
        WHEN 10 THEN 'Mary' WHEN 11 THEN 'Patricia' WHEN 12 THEN 'Jennifer' WHEN 13 THEN 'Linda' WHEN 14 THEN 'Elizabeth'
        WHEN 15 THEN 'Barbara' WHEN 16 THEN 'Susan' WHEN 17 THEN 'Jessica' WHEN 18 THEN 'Sarah' ELSE 'Karen'
    END AS first_name,
    CASE MOD(SEQ4(), 15)
        WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Williams' WHEN 3 THEN 'Jones' WHEN 4 THEN 'Brown'
        WHEN 5 THEN 'Davis' WHEN 6 THEN 'Miller' WHEN 7 THEN 'Wilson' WHEN 8 THEN 'Moore' WHEN 9 THEN 'Taylor'
        WHEN 10 THEN 'Anderson' WHEN 11 THEN 'Thomas' WHEN 12 THEN 'Jackson' WHEN 13 THEN 'White' ELSE 'Harris'
    END || SEQ4() AS last_name,
    'member' || SEQ4() || '@example.com' AS email,
    DATEADD(day, -UNIFORM(10, 3650, RANDOM()), CURRENT_DATE()) AS join_date,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Troon Rewards'
        WHEN 2 THEN 'Gold'
        ELSE 'Platinum'
    END AS membership_tier,
    UNIFORM(1, 10, RANDOM()) AS home_course_id,
    CASE WHEN UNIFORM(1, 100, RANDOM()) > 10 THEN 'Active' ELSE 'Inactive' END AS status,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 1000));

-- ============================================================================
-- 3. Tee Times (5000 rows - rolling 90 days history + 30 days future)
-- ============================================================================
INSERT INTO TEE_TIMES
SELECT
    'BK-' || LPAD(SEQ4(), 6, '0') AS booking_id,
    UNIFORM(1, 10, RANDOM()) AS course_id,
    (ABS(RANDOM()) % 1000) + 1000 AS member_id, -- Maps to member_ids 1000-1999
    DATEADD(day, -UNIFORM(-30, 90, RANDOM()), CURRENT_DATE()) AS play_date,
    TIME_FROM_PARTS(UNIFORM(6, 17, RANDOM()), UNIFORM(0, 5, RANDOM())*10, 0) AS booking_time,
    UNIFORM(1, 4, RANDOM()) AS players_count,
    CASE 
        WHEN UNIFORM(0, 1, RANDOM()) = 1 THEN 150.00 
        ELSE 250.00 
    END AS price_per_player,
    players_count * price_per_player AS total_revenue,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'App'
        WHEN 2 THEN 'Web'
        ELSE 'Phone'
    END AS booking_channel,
    CASE 
        WHEN play_date > CURRENT_DATE() THEN 'Booked'
        WHEN UNIFORM(1, 100, RANDOM()) < 5 THEN 'No Show'
        WHEN UNIFORM(1, 100, RANDOM()) < 10 THEN 'Cancelled'
        ELSE 'Completed'
    END AS status,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- 4. Pro Shop Sales (5000 rows)
-- ============================================================================
INSERT INTO PRO_SHOP_SALES
SELECT
    'TX-' || LPAD(SEQ4(), 8, '0') AS transaction_id,
    UNIFORM(1, 10, RANDOM()) AS course_id,
    (ABS(RANDOM()) % 1000) + 1000 AS member_id,
    DATEADD(minute, -UNIFORM(0, 129600, RANDOM()), CURRENT_TIMESTAMP()) AS sale_date, -- Last 90 days
    CASE UNIFORM(1, 4, RANDOM())
        WHEN 1 THEN 'Apparel'
        WHEN 2 THEN 'Equipment'
        WHEN 3 THEN 'Accessories'
        ELSE 'Balls'
    END AS item_category,
    CASE item_category
        WHEN 'Apparel' THEN 'Troon Polo Shirt'
        WHEN 'Equipment' THEN 'Titleist Driver'
        WHEN 'Accessories' THEN 'Golf Towel'
        ELSE 'Pro V1 Dozen'
    END AS item_name,
    UNIFORM(1, 3, RANDOM()) AS quantity,
    CASE item_category
        WHEN 'Apparel' THEN 75.00
        WHEN 'Equipment' THEN 499.00
        WHEN 'Accessories' THEN 25.00
        ELSE 55.00
    END AS unit_price,
    quantity * unit_price AS total_amount,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 5000));

-- ============================================================================
-- 5. Course Reviews (500 rows)
-- ============================================================================
INSERT INTO COURSE_REVIEWS
SELECT
    'REV-' || LPAD(SEQ4(), 5, '0') AS review_id,
    UNIFORM(1, 10, RANDOM()) AS course_id,
    (ABS(RANDOM()) % 1000) + 1000 AS member_id,
    DATEADD(day, -UNIFORM(0, 180, RANDOM()), CURRENT_DATE()) AS review_date,
    UNIFORM(1, 5, RANDOM()) AS rating,
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'The greens were incredibly fast today. Loved the challenge.'
        WHEN 2 THEN 'Pace of play was a bit slow on the back 9, but the course conditions were pristine.'
        WHEN 3 THEN 'Staff was very friendly and the rental clubs were high quality. Will come back.'
        WHEN 4 THEN 'Bunkers needed some work, but overall a great layout.'
        ELSE 'Best round of golf I have played all year. The views are spectacular.'
    END AS review_text,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 500));

-- ============================================================================
-- 6. Maintenance Logs (200 rows)
-- ============================================================================
INSERT INTO MAINTENANCE_LOGS
SELECT
    'LOG-' || LPAD(SEQ4(), 5, '0') AS log_id,
    UNIFORM(1, 10, RANDOM()) AS course_id,
    DATEADD(day, -UNIFORM(0, 60, RANDOM()), CURRENT_DATE()) AS log_date,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Irrigation'
        WHEN 2 THEN 'Mowing'
        ELSE 'Aeration'
    END AS maintenance_type,
    CASE maintenance_type
        WHEN 'Irrigation' THEN 'Repaired a leak on hole 4 sprinkler head. System pressure normalized.'
        WHEN 'Mowing' THEN 'Mowed all fairways and tees. Height of cut set to 0.5 inches.'
        ELSE 'Greens aeration completed on holes 1-9. Top dressing applied.'
    END AS description,
    'Tech-' || UNIFORM(1, 5, RANDOM()) AS technician_name,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 200));

-- ============================================================================
-- 7. Club Policies (Static content)
-- ============================================================================
INSERT INTO CLUB_POLICIES (policy_id, title, category, last_updated, content)
VALUES
('POL-001', 'Dress Code Policy', 'Dress Code', '2024-01-01', 'Proper golf attire is required at all times. Men must wear collared shirts. No denim allowed. Shorts must be Bermuda length. Soft spikes only.'),
('POL-002', 'Cancellation Policy', 'Cancellation', '2024-01-01', 'Cancellations must be made at least 24 hours in advance to avoid a cancellation fee. No-shows will be charged the full rate.'),
('POL-003', 'Pace of Play', 'Etiquette', '2024-01-01', 'Players are expected to complete 18 holes in 4 hours and 15 minutes or less. Please keep up with the group in front of you.'),
('POL-004', 'Rain Check Policy', 'Weather', '2024-01-01', 'Rain checks will be issued if the course is closed due to weather. Prorated based on holes played.'),
('POL-005', 'Cart Policy', 'Equipment', '2024-01-01', 'Golf carts must remain on paths around tees and greens. 90-degree rule is in effect unless otherwise posted.');

-- ============================================================================
-- 8. RealFood Projects (50 rows)
-- ============================================================================
INSERT INTO REALFOOD_PROJECTS
SELECT
    'RF-' || LPAD(SEQ4(), 4, '0') AS project_id,
    'Project ' || SEQ4() || ' - ' || 
    CASE UNIFORM(1, 5, RANDOM())
        WHEN 1 THEN 'Grand Hotel Kitchen Reno'
        WHEN 2 THEN 'Downtown Bistro Concept'
        WHEN 3 THEN 'Resort F&B Strategy'
        WHEN 4 THEN 'Stadium Concession Design'
        ELSE 'Corporate Cafeteria Upgrade'
    END AS project_name,
    CASE UNIFORM(1, 10, RANDOM())
        WHEN 1 THEN 'Marriott International'
        WHEN 2 THEN 'Hilton Hotels'
        WHEN 3 THEN 'Four Seasons'
        WHEN 4 THEN 'Hyatt Regency'
        WHEN 5 THEN 'Boston Red Sox'
        WHEN 6 THEN 'Google Campus'
        WHEN 7 THEN 'University of Texas'
        WHEN 8 THEN 'Wynn Resorts'
        WHEN 9 THEN 'Aramark'
        ELSE 'Sodexo'
    END AS client_name,
    CASE UNIFORM(1, 6, RANDOM())
        WHEN 1 THEN 'Hotels & Resorts'
        WHEN 2 THEN 'Restaurants & Bars'
        WHEN 3 THEN 'Entertainment & Recreation'
        WHEN 4 THEN 'Workplace & Municipal'
        WHEN 5 THEN 'Education'
        ELSE 'Healthcare'
    END AS sector,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Foodservice Design'
        WHEN 2 THEN 'Strategy & Concept'
        ELSE 'F&B Operations'
    END AS service_type,
    CASE UNIFORM(1, 3, RANDOM())
        WHEN 1 THEN 'Active'
        WHEN 2 THEN 'Completed'
        ELSE 'Planning'
    END AS status,
    DATEADD(month, -UNIFORM(0, 24, RANDOM()), CURRENT_DATE()) AS completion_date,
    UNIFORM(50000, 2000000, RANDOM()) AS project_budget,
    CURRENT_TIMESTAMP() AS created_at
FROM TABLE(GENERATOR(ROWCOUNT => 50));

-- ============================================================================
-- 9. RealFood Services (Static content based on website)
-- ============================================================================
INSERT INTO REALFOOD_SERVICES (service_id, service_name, category, description)
VALUES
('SVC-001', 'Foodservice Facility Design', 'Design', 'Comprehensive kitchen and service area layout design. Includes equipment specification, workflow optimization, and health code compliance. We focus on efficiency and chef-friendly workspaces.'),
('SVC-002', 'Hospitality Interior Design', 'Design', 'Creating vibe-setting interiors that enhance the guest experience. From furniture selection to lighting and decor, we ensure the aesthetic matches the culinary concept.'),
('SVC-003', 'Concept & Brand Development', 'Strategy', 'Developing unique restaurant and bar concepts from scratch. We define the culinary identity, target audience, menu strategy, and visual brand elements.'),
('SVC-004', 'Food & Beverage Operations', 'Operations', 'Operational consulting to improve efficiency and profitability. We analyze menu engineering, labor costs, inventory management, and service standards.'),
('SVC-005', 'Strategic Advisory', 'Strategy', 'High-level business planning for hospitality groups. We assist with feasibility studies, market analysis, and long-term growth strategies.'),
('SVC-006', 'Menu Development', 'Operations', 'Culinary consulting to create profitable and delicious menus. We work with chefs to source ingredients, design dishes, and price items for maximum margin.'),
('SVC-007', 'Equipment Procurement', 'Design', 'Sourcing and purchasing commercial kitchen equipment. We leverage vendor relationships to get the best pricing and ensure timely delivery.'),
('SVC-008', 'Staff Training & Culture', 'Operations', 'Training programs for front-of-house and back-of-house staff. We focus on service excellence, product knowledge, and building a positive team culture.'),
('SVC-009', 'Rebranding & Turnaround', 'Strategy', 'Revitalizing struggling concepts. We identify pain points, refresh the brand, and implement operational changes to drive traffic and revenue.'),
('SVC-010', 'Master Planning', 'Design', 'Large-scale planning for multi-outlet venues like resorts, campuses, and stadiums. We design the overall F&B ecosystem for optimal flow and variety.');

-- ============================================================================
-- Validation
-- ============================================================================
SELECT 'Data Generation Complete' AS STATUS;
SELECT 'GOLF_COURSES', COUNT(*) FROM GOLF_COURSES
UNION ALL SELECT 'MEMBERS', COUNT(*) FROM MEMBERS
UNION ALL SELECT 'TEE_TIMES', COUNT(*) FROM TEE_TIMES
UNION ALL SELECT 'PRO_SHOP_SALES', COUNT(*) FROM PRO_SHOP_SALES
UNION ALL SELECT 'REALFOOD_PROJECTS', COUNT(*) FROM REALFOOD_PROJECTS;
