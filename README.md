# Samia Carchaf . Jarvis Consulting

I recently completed a Master's degree in Computer Science with a specialization in Artificial Intelligence from UQAC and a Software Engineering degree from Polytech Tours, and have been building hands-on experience in machine learning and data engineering through projects at Jarvis Consulting Group. My background includes working with Python, SQL, PostgreSQL, Docker, Bash scripting, and Linux to build data collection, automation, and infrastructure solutions. I'm particularly focused on using AI and machine learning to make development processes smarter and more efficient, not just as an end product, but as a tool woven into the way I build software.

## Skills

**Proficient:** Python, Machine Learning, Linux/Bash, RDBMS/SQL, Docker, Git

**Competent:** Agile/Scrum, Power BI, Data Modeling, Databricks, Apache Spark

**Familiar:** Java, Azure ML, AWS, MLflow, Tableau

## Jarvis Projects

Project source code: [https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf)


**Cluster Monitor** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/linux_sql)]:
      
  - Designed and implemented a Linux Cluster Monitoring Agent to collect hardware specifications and real-time resource usage data from Linux servers.
  - Provisioned a PostgreSQL database with Docker for persistent storage.
  - Automated continuous data collection every minute using crontab, enabling real-time cluster monitoring for the LCA team.

**RDBMS and SQL** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/sql)]:
      
  - Designed and implemented a relational database schema using PostgreSQL, applying normalization principles and enforcing data integrity through primary keys, foreign keys, and constraints.
  - Wrote optimized SQL queries to answer business questions.

**Python Data Analytics** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/python_data_analytics)]:
      
  - Built an end-to-end Python analytics pipeline on the U.S. CFPB Consumer Complaint Database.
  - Conducted data profiling, cleaning, and feature engineering with Pandas, including company-tier segmentation and time-series trends.
  - Produced interactive visualizations across 7 key findings, including market concentration, product mix evolution, and a seven-dimension Bureau Accountability Scorecard.

**Spark** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/databricks/pyspark)]:
      
  - Provisioned a Hadoop cluster on GCP Dataproc and set up a Hive external table on HDFS to store the World Development Indicators (WDI) dataset (~21.7M rows).
  - Wrote PySpark DataFrame operations in a Zeppelin notebook, using filtering, groupBy aggregations, and joins.
  - Analyzed historical GDP growth trends by country, including identifying each country's peak GDP growth year through DataFrame transformations.

**Databricks** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/databricks)]:
      
  - Built a batch ETL pipeline in Azure Databricks for fraud detection analytics, ingesting transaction, card, user, merchant, and fraud-label data from Azure SQL Database and ADLS Gen2 into a Bronze/Silver/Gold medallion architecture, producing 6 gold tables for a Databricks fraud analytics dashboard.
  - Built a DLT (Lakeflow Declarative Pipelines) pipeline ingesting daily stock market data from the Alpha Vantage API, computing 7/30/90-day price and volume trend metrics using Spark window functions.
  - Applied SCD Type 1 change tracking, designed streaming tables vs. materialized views based on data update patterns, and secured API credentials using Databricks secret scopes.
  - Orchestrated both pipelines with Databricks Jobs on daily schedules, including automated dashboard refresh, and used Unity Catalog for governed table management across both projects.

**Credit Default Risk Scoring** [[GitHub](https://github.com/jarviscanada/jarvis_data_eng_SamiaCarchaf/tree/master/capstone)]:
      
  - Built an end-to-end credit scoring pipeline on the Home Credit Default Risk dataset (Kaggle), covering EDA, preprocessing, and feature engineering across ~307K loan applications and 122 features.
  - Engineered features including financial ratios, missingness indicators, and bureau credit history aggregations, validated through correlation and multicollinearity (VIF) analysis.
  - Trained and compared Logistic Regression, Random Forest, and Gradient Boosting models using AUROC, Gini, KS, and AUPRC metrics.
  - Developed a production-ready Scikit-learn Pipeline and generated model validation documentation following financial industry best practices.


## Highlighted Projects
**Credit Card Fraud Detection** [[GitHub](https://github.com/samias9/fraude_bancaire)]: Developed a fraud detection system analyzing 590K+ transactions from the IEEE-CIS dataset using XGBoost. Addressed extreme class imbalance (0.3% fraud rate) using SMOTE and class weight adjustment. Designed a Power BI dashboard for real-time monitoring of suspicious transactions. Technologies used: Python, XGBoost, SMOTE, scikit-learn, Pandas, Power BI.


## Professional Experiences

**Machine Learning Engineer, Jarvis (2026-present)**: Worked in an Agile, GitFlow-based development environment, delivering hands-on machine learning and data engineering projects, including predictive modeling, ETL and DLT pipelines, customer segmentation, and model explainability, using Python, SQL, Apache Spark, Databricks, and cloud platforms.

**Data Infrastructure Manager, Médecins francophones du Canada (2026-01 to 2026-04)**: Designed and deployed the organization's core data architecture, migrating historical data into a structured SQL environment. Built automated ETL pipelines between CiviCRM and Power BI, reducing report production time by 80%. Created interactive Power BI dashboards for predictive analysis of membership trends and KPI monitoring.

**Data Scientist Intern, Francoflex (2025-07 to 2025-12)**: Developed an end-to-end ML pipeline for accented French speech recognition, processing 3K+ audio samples. Improved model accuracy by 35% through data augmentation techniques. Set up a replicable training infrastructure using Python, Docker, and MLflow.

**Data Analyst Intern, ARSENE (2024-06 to 2024-08)**: Optimized complex SQL queries reducing execution times by 25%. Conducted data quality analysis identifying 20+ critical anomalies in ETL pipelines. Built internal dashboards to monitor data quality using Python and SQL.


## Education
**University of Québec at Chicoutimi (UQAC) (2024-2026)**, Master of Science, Computer Science - Artificial Intelligence
- Specializations: Machine Learning, NLP, Deep Learning, Data Mining

**Polytech Tours Engineering School (2020-2025)**, Engineering Degree, Software Engineering
- Focus: Big Data, Statistics, Algorithms, Relational Databases


## Miscellaneous
- Power BI (DataCamp): Data visualization and DAX proficiency
- Fraud Detection in Python (DataCamp): ML application using XGBoost and SMOTE
- Data Analytics (IBM): ID: 25UDNA8FVK48
- French (Native)
- English (Professional - TOEIC 890/990)