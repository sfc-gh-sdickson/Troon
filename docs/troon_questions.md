<img src="../Snowflake_Logo.svg" alt="Snowflake Logo" width="300">

# Troon Intelligence Agent - Sample Questions

This document contains 18 sample questions to test the Troon Intelligence Agent, covering simple data retrieval, complex analysis, machine learning predictions, and RealFood Hospitality business.

## Simple Questions (Data Retrieval)

1. **"What was the total revenue for Troon North Golf Club last month?"**
   - *Target*: `CourseAnalyst`
   - *Data*: `SV_COURSE_PERFORMANCE` (Sum revenue, filter by course and date)

2. **"How many active Platinum members do we currently have?"**
   - *Target*: `MemberAnalyst`
   - *Data*: `SV_MEMBER_ANALYTICS` (Count members, filter by tier and status)

3. **"List the top 5 selling items in the Pro Shop by revenue."**
   - *Target*: `ProShopAnalyst`
   - *Data*: `SV_PRO_SHOP_INSIGHTS` (Group by item, sum amount, order by desc)

4. **"What is the cancellation policy for rain?"**
   - *Target*: `PolicySearch`
   - *Data*: `CLUB_POLICIES_SEARCH` (Semantic search for "cancellation" and "rain")

5. **"Show me the most recent maintenance log for Kapalua."**
   - *Target*: `MaintenanceSearch`
   - *Data*: `MAINTENANCE_LOGS_SEARCH` (Search logs, filter by course)

## Complex Questions (Analysis)

6. **"Which golf course has the highest average revenue per booking on weekends?"**
   - *Target*: `CourseAnalyst`
   - *Data*: `SV_COURSE_PERFORMANCE` (Avg revenue, filter by day of week)

7. **"What is the average tenure of members who spent more than $500 in the pro shop last year?"**
   - *Target*: `MemberAnalyst`
   - *Data*: `SV_MEMBER_ANALYTICS` (Avg tenure, filter by total_spend > 500)

8. **"Compare the total revenue from 'Apparel' vs 'Equipment' sales for the last quarter."**
   - *Target*: `ProShopAnalyst`
   - *Data*: `SV_PRO_SHOP_INSIGHTS` (Sum revenue by category)

9. **"Summarize the main complaints from member reviews regarding pace of play."**
   - *Target*: `ReviewSearch`
   - *Data*: `COURSE_REVIEWS_SEARCH` (Search for "pace of play", summarize text)

10. **"Identify courses where maintenance logs mention 'irrigation' issues."**
    - *Target*: `MaintenanceSearch`
    - *Data*: `MAINTENANCE_LOGS_SEARCH` (Search "irrigation", list courses)

## Machine Learning Questions (Predictions)

11. **"Predict the churn risk for all our 'Troon Rewards' tier members."**
    - *Target*: `PredictChurn`
    - *Function*: `PREDICT_CHURN_RISK('Troon Rewards')`

12. **"How many members are candidates for an upgrade based on a $1000 spend threshold?"**
    - *Target*: `IdentifyUpgrades`
    - *Function*: `IDENTIFY_UPGRADE_CANDIDATES(1000)`

13. **"What is the risk of no-shows for bookings in the next 7 days?"**
    - *Target*: `PredictNoShow`
    - *Function*: `PREDICT_NO_SHOW_RISK(7)`

14. **"Which membership tier has the highest proportion of high-risk members?"**
    - *Target*: `PredictChurn`
    - *Function*: `PREDICT_CHURN_RISK(NULL)` (Requires agent to analyze the summary breakdown)

15. **"Are there any high-value members at risk of leaving?"**
    - *Target*: `PredictChurn` + `MemberAnalyst`
    - *Reasoning*: Combines churn prediction with spend analysis.

## RealFood Hospitality Questions

16. **"List all active RealFood projects in the Hotels & Resorts sector."**
    - *Target*: `RealFoodProjectAnalyst`
    - *Data*: `SV_REALFOOD_PROJECTS` (Filter by Status='Active', Sector='Hotels & Resorts')

17. **"What RealFood services are available for kitchen design?"**
    - *Target*: `RealFoodServiceSearch`
    - *Data*: `REALFOOD_SERVICES_SEARCH` (Semantic search for 'kitchen design')

18. **"What is the total budget for completed Strategy projects?"**
    - *Target*: `RealFoodProjectAnalyst`
    - *Data*: `SV_REALFOOD_PROJECTS` (Sum budget, filter by Status='Completed', Type='Strategy')
