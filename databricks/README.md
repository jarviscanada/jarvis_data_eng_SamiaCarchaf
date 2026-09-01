# Introduction

This project demonstrates how Databricks can be used to build end-to-end data pipelines using two different approaches: a traditional notebook-based ETL pipeline and a declarative DLT (Delta Live Tables / Lakeflow) pipeline. The business context is to take raw data from external sources and transform it into clean, analysis-ready tables that power dashboards and support decision-making.

The project contains two implementations. The first is a batch ETL pipeline in Azure Databricks for financial transaction fraud analysis, built by ingesting transaction, card, user, merchant category, and fraud label data from multiple sources and transforming it through a medallion architecture into gold tables used for fraud analytics. The second is a DLT pipeline in Databricks for stock market trend analysis, built by ingesting daily stock data from the Alpha Vantage API and transforming it through bronze, silver, and gold layers to produce price and volume trend metrics.

Across both implementations, I worked with Azure Databricks, PySpark, Delta Lake, Unity Catalog, Azure SQL Database, Azure Data Lake Storage, external APIs, Databricks Jobs, and Databricks Dashboards.

# Implementation

## 1. ETL in Databricks (Fraud Detection)

### Business Goal

This pipeline was built to support fraud analytics on financial transaction data. The goal was to bring together data from multiple source systems, clean and standardize it, enrich it with reference data, and produce gold tables that answer business questions about fraud patterns, risky users, and suspicious merchants.

### Dataset

The pipeline uses a Kaggle-sourced financial transactions dataset made up of:

- `transactions_data.csv` — individual transaction records (~13.3 million rows)
- `cards_data.csv` — card-level account information
- `users_data.csv` — customer demographic information
- `mcc_codes.json` — merchant category code lookup data
- `train_fraud_labels.json` — fraud labels for a subset of transactions

Notebooks: `bronze_ingestion.ipynb`, `silver_transform.ipynb`, `gold_aggregations.ipynb`

### Pipeline Development

- Loaded `transactions_data.csv` and `cards_data.csv` into an Azure SQL Database and connected to Databricks over JDBC
- Uploaded `users_data.csv`, `mcc_codes.json`, and `train_fraud_labels.json` to Azure Data Lake Storage Gen2 and registered them as a Unity Catalog external location
- Parsed the two single-object JSON files manually using `spark.read.text()` + `json.loads()`, since they were not in JSON Lines format
- Built bronze, silver, and gold notebooks following the medallion architecture
- Cleaned data types, standardized formats (dates, currency strings, boolean flags), and joined transactions with MCC descriptions and fraud labels
- Built six gold tables covering daily fraud summaries, fraud by merchant, fraud by user, user behavior change after a first fraud event, fraud by specific merchant, and fraud by time of day
- Created a Databricks dashboard on top of the gold tables
- Orchestrated the pipeline with a Databricks Job

### Technologies Used

- Azure Databricks
- PySpark
- Azure SQL Database (JDBC)
- Azure Data Lake Storage Gen2
- Unity Catalog (external locations, storage credentials)
- Databricks Jobs
- Databricks Dashboard

### Architecture

**Ingestion**
- `transactions_data.csv` and `cards_data.csv` → Azure SQL Database → JDBC into Databricks
- `users_data.csv`, `mcc_codes.json`, `train_fraud_labels.json` → ADLS Gen2 → Unity Catalog external location

**Bronze Layer**
- Raw copies of all five sources, saved as Delta tables with minimal transformation

**Silver Layer**
- Cast columns to correct types, decomposed transaction dates into year/month/day/hour/day-of-week fields
- Joined transactions with MCC descriptions and fraud labels
- Cleaned card and user tables (date parsing, boolean conversion, currency string cleanup)

**Gold Layer**
- `fraud_daily_summary_gold`, `fraud_merchant_gold`, `fraud_user_gold`, `user_behavior_change_gold`, `fraud_by_specific_merchant_gold`, `fraud_by_time_of_day_gold`

**Dashboard**
- Built from the gold tables, with filters for interactive exploration of fraud trends

**Orchestration**
- Databricks Job with tasks sequenced Bronze → Silver → Gold → Dashboard refresh

## 2. DLT in Databricks (Stock Market Trend Analysis)

### Business Goal

This pipeline was built to support stock trend analytics using daily stock market data. The goal was to automatically ingest data for four stock symbols from an external API, process it through a declarative medallion pipeline, compute price and volume trend metrics, and make the results available through a scheduled, dashboard-ready workflow.

### Dataset

The pipeline uses stock market data from the [Alpha Vantage API](https://www.alphavantage.co/documentation/), covering four symbols: AAPL, MSFT, GOOGL, and AMZN. Three endpoints are used:

- `GLOBAL_QUOTE` — latest daily quote per symbol
- `TIME_SERIES_DAILY` — ~100 days of daily open/high/low/close/volume history per symbol
- `OVERVIEW` — company reference data (name, sector, industry, description, key financial ratios)

Pipeline source files: `bronze_ingestion.py`, `silver_transform.py`, `gold_aggregations.py`

### Pipeline Development

- Obtained an Alpha Vantage API key and secured it using a Databricks secret scope (`alpha-vantage`), read at runtime with `dbutils.secrets.get()`
- Built a DLT pipeline in Databricks using the medallion architecture, split across three source files
- Designed bronze tables to ingest raw API responses per symbol, with `time.sleep()` delays added between API calls to stay within Alpha Vantage's rate limit (5 requests/minute, 25 requests/day)
- Designed silver tables to clean and standardize the bronze data — casting price and volume fields from strings to numeric types, converting date strings to proper `date` types, and stripping the `%` symbol from percentage fields
- Applied SCD Type 1 to the company info table using `dlt.create_streaming_table()` + `dlt.apply_changes()`, so that company attributes are overwritten in place rather than versioned
- Built gold tables computing price and volume trends using Spark window functions (`Window.partitionBy("symbol").orderBy("date")` with `lag()`) to compare each day's values against 7, 30, and 90 days prior
- Built a Databricks dashboard on top of the gold tables
- Created a Databricks Job to run the pipeline and refresh the dashboard on a daily schedule

### Technologies Used

- Databricks
- DLT / Lakeflow Declarative Pipelines
- PySpark (window functions, `regexp_replace`, `to_date`, type casting)
- Alpha Vantage API
- Databricks Secrets (CLI-managed secret scope)
- Unity Catalog
- Databricks Jobs
- Databricks Dashboard

### Architecture

**Ingestion**
- Alpha Vantage API, called once per symbol per table, with rate limiting handled via `time.sleep()` between calls

**Bronze Layer**
- `bronze_quotes`, `bronze_price_history`, `bronze_company_info` — raw API output per symbol, stored as streaming tables that append new data on each run

**Silver Layer**
- `silver_quotes`, `silver_price_history` — cleaned, correctly typed versions of the bronze tables, implemented as tables reading their source with `dlt.read()`
- `silver_company_info` — built using `dlt.read_stream()` (with `skipChangeCommits` enabled, since the bronze source is fully overwritten on each run) feeding into `dlt.apply_changes()` with `stored_as_scd_type = 1`, so each company's latest attributes overwrite the previous version

**Gold Layer**
- `gold_price_trends` — price change and percentage price change over 7, 30, and 90 days, computed with `lag()` over a window partitioned by symbol and ordered by date
- `gold_volume_trends` — same approach applied to trading volume

**Dashboard**
- Price trend line chart (close price over time, colored by symbol)
- Table of the latest 7/30/90-day percentage price changes per symbol
- Volume bar chart over time, colored by symbol
- Best performer of the day card, based on the highest daily `change_percent`

**Orchestration**
- Databricks Job with two tasks: `run_stock_pipeline` (runs the DLT pipeline) and `refresh_dashboard` (refreshes the published dashboard, set to depend on `run_stock_pipeline` succeeding), on a daily schedule

### Design Decisions

**Streaming Tables vs. Materialized Views**
Bronze tables are streaming tables by default, since they only append new API data on each run rather than recomputing from scratch. Most silver tables use `dlt.read()`, which behaves like a materialized view and recomputes on each run — appropriate here since the silver transformations are lightweight recasts of the bronze data. `silver_company_info` is an explicit streaming table because `dlt.apply_changes()` requires one.

**SCD Type**
`silver_company_info` uses SCD Type 1. Company reference data (sector, industry, name) changes rarely, and the project only needs the current value rather than a history of changes, so overwriting in place is simpler and sufficient.

**Triggered vs. Continuous**
The pipeline runs in Triggered mode. Given Alpha Vantage's daily and per-minute rate limits, a continuously running pipeline would exceed the quota almost immediately; a once-daily triggered run fits well within the limit.

# Future Improvement

**Add Data Quality Validation**
Introduce `@dlt.expect` constraints (e.g., non-null symbols, valid date ranges, non-negative prices/volumes) to catch bad records before they flow from bronze to silver or silver to gold, instead of relying only on manual debugging.

**Add Monitoring and Alerting**
Add job failure notifications and a lightweight operational log/dashboard so pipeline or API issues (e.g., hitting the Alpha Vantage rate limit) are surfaced immediately instead of being discovered on the next manual check.

**Expand Symbol Coverage and Historical Depth**
Move beyond the four current symbols and the ~100-day "compact" history to a configurable symbol list and full historical range, which would require a more deliberate API request budget given Alpha Vantage's rate limits.
