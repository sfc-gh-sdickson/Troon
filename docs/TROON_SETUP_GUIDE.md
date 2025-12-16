<img src="../Snowflake_Logo.svg" width="200">

# Troon Intelligence Agent - Setup Guide

This guide provides comprehensive, step-by-step instructions to deploy the complete Troon Intelligence Agent solution.

---

## 📋 Prerequisites

Before starting, ensure you have:

1.  **Snowflake Account**: Enterprise Edition or higher (required for Cortex features).
2.  **Permissions**: Access to a role with `SYSADMIN` privileges (or equivalent ability to create databases, warehouses, and integration objects).
3.  **Snowflake Notebooks**: Enabled in your Snowflake account.
4.  **Anaconda**: Enabled in your Snowflake account (for ML packages).

---

## 🛠️ Deployment Flow

Follow these steps sequentially to build the entire platform.

### Phase 1: Foundation (Database & Data)

#### Step 1: Initialize Database & Schema
Create the core container for the application.
*   **Script**: `sql/setup/01_database_and_schema.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW SCHEMAS IN DATABASE TROON_INTELLIGENCE;
    -- Should list: RAW, ANALYTICS, ML_MODELS
    ```

#### Step 2: Create Tables
Define the schema for Courses, Members, Tee Times, etc.
*   **Script**: `sql/setup/02_create_tables.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW TABLES IN SCHEMA TROON_INTELLIGENCE.RAW;
    -- Should list 7 tables
    ```

#### Step 3: Generate Synthetic Data
Populate the tables with realistic test data.
*   **Script**: `sql/data/03_generate_synthetic_data.sql`
*   **Action**: Run all queries. *Note: This may take a few minutes.*
*   **Verification**:
    ```sql
    SELECT COUNT(*) FROM TROON_INTELLIGENCE.RAW.TEE_TIMES;
    -- Should return ~5,000
    ```

---

### Phase 2: Intelligence Layer (Views & Search)

#### Step 4: Create Analytical & Feature Views
Create feature views for ML training.
*   **Script**: `sql/views/04_create_views.sql`
*   **Action**: Run all queries.

#### Step 5: Create Semantic Views (Cortex Analyst)
Create the semantic layer that allows the LLM to understand your data structure.
*   **Script**: `sql/views/05_create_semantic_views.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW SEMANTIC VIEWS IN SCHEMA TROON_INTELLIGENCE.ANALYTICS;
    -- Should list 3 views
    ```

#### Step 6: Create Cortex Search Services
Enable vector search on unstructured text fields.
*   **Script**: `sql/search/06_create_cortex_search.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW CORTEX SEARCH SERVICES IN SCHEMA TROON_INTELLIGENCE.RAW;
    -- Should list 3 services
    ```

---

### Phase 3: Predictive Modeling (Machine Learning)

#### Step 7: Train ML Models
Train the Churn, No-Show, and Upgrade models using Snowpark.
1.  Open **Snowflake Notebooks** in the UI.
2.  Create a new Notebook.
3.  **Import File**: Upload `notebooks/troon_ml_models.ipynb`.
4.  **Run All Cells**: Execute the notebook to train and register the models in the Model Registry.
5.  **Verification**: Look for "Successfully registered" messages in the notebook output.

#### Step 8: Create ML SQL Functions
Expose the trained models as SQL functions for the Agent to call.
*   **Script**: `sql/ml/07_ml_model_functions.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SELECT TROON_INTELLIGENCE.ML_MODELS.PREDICT_CHURN_RISK('Gold');
    -- Should return a prediction summary string
    ```

---

### Phase 4: Orchestration (The Agent)

#### Step 9: Configure Intelligence Agent
Assemble all tools into the final conversational agent.
*   **Script**: `sql/agent/08_intelligence_agent.sql`
*   **Action**: Run all queries.
*   **Verification**:
    ```sql
    SHOW AGENTS IN SCHEMA TROON_INTELLIGENCE.ANALYTICS;
    -- Should list TROON_INTELLIGENCE_AGENT
    
    DESC AGENT TROON_INTELLIGENCE_AGENT;
    -- Should show tools
    ```

---

## 🧪 Testing

Refer to `docs/troon_questions.md` for a curated list of 15 questions to validate all capabilities.

**Example Test:**
> "Predict the churn risk for our Gold members"

This will:
1.  Call `PREDICT_CHURN_RISK` function.
2.  Analyze feature view data for 'Gold' members.
3.  Return aggregated risk distribution.

