# CFPB Consumer Complaint Analysis

## Introduction

This project explores the **U.S. Consumer Financial Protection Bureau (CFPB) Consumer Complaint Database**, a publicly available federal dataset containing ~1.28 million complaints filed against financial institutions between December 2011 and May 2019.

Every row in this dataset is a "failure event": the moment a consumer escalated to a federal regulator because a financial product didn't work for them. That makes it a high-signal dataset for risk, compliance, and customer experience teams.

The analysis covers the full data science lifecycle : ingestion, profiling, cleaning, feature engineering, exploratory analysis, and applied machine learning, implemented in a single-machine pandas pipeline on a ~1.6 GB in-memory dataset.

**Dataset source:** [Kaggle - CFPB Consumer Complaint Database](https://www.kaggle.com/datasets/selener/consumer-complaint-database)

## Business Questions

1. Who attracts the most complaints, and how concentrated is the market?
2. Which products and issues are driving volume?
3. How has the mix changed over time? Are there visible external events?
4. What does resolution look like ? and where does the system fail consumers?
5. Are there segments (company tier, geography) with weaker operational performance?
6. What would I recommend doing about it?

## Technologies Used

- **Python 3** - pandas, NumPy, Matplotlib, Seaborn, Plotly
- **scikit-learn** - Random Forest, Logistic Regression, train/test split, classification metrics
- **Jupyter Notebook** - end-to-end analysis and visualization
- **PostgreSQL / Docker** - upstream data engineering layer
- **Git / GitFlow** - feature branch workflow

## Notebook Walkthrough

| Section                            | Description |
|------------------------------------|---|
| 1 - Setup                          | Environment config, color palette, display options |
| 2 - Load                           | Ingest 1.28M rows from CSV |
| 3 - Profiling                      | Missing value audit, duplicate check, date range validation |
| 4 - Cleaning & Feature Engineering | Date parsing, binary flags, lag days, company tiers |
| 5 - Headline Numbers               | Single-slide KPI summary |
| 6-12 - Six Core Insights           | EDA with Plotly visualizations (detailed below) |
| 13 - Limitations                   | Taxonomy drift, missingness, pre-/post-2017 data splits |
| 14 - Recommendations               | Actionable findings across analytics, data engineering, and CX |
| 15 - Roadmap                       | Short/medium/long-term implementation plan |
| 16 - Closing Summary               | One-paragraph executive takeaway |
| 17a - Dispute Risk Classifier      | Random Forest ML model |
| 17b - Untimely Response Predictor  | Random Forest ML model |

## Key Insights

### Insight 1 - Market Concentration Is Extreme

Out of 5,275 companies, the top 10 account for **~52% of all complaints**. The three credit bureaus, Equifax, Experian, and TransUnion, alone represent roughly **25% of the entire dataset**. A regulator auditing only the top 10 companies covers more than half of all consumer harm signals in the system.


### Insight 2 - Mortgage and Credit Reporting Are Trading Places

Mortgage was the dominant category in 2012 (~50% of volume). By 2019, it had fallen to ~9%. Meanwhile, Credit Reporting went from near-zero to over 50% of yearly volume. Two drivers: the post-2008 mortgage crisis tail receding, and the Equifax breach (September 2017) pushing credit-data accuracy into public awareness.

### Insight 3 - Operational Quality Varies Sharply by Company Tier

Top-tier companies (Tier 1) miss the CFPB's 15-day response deadline less than 1% of the time. Long-tail companies (Tier 3) miss it **9.5% of the time**, a 9× gap. Resolution depth also declines as you move down tiers.

### Insight 4 - Resolution Is Fast but Shallow

The system responds on time 97.5% of the time, but only **18.6%** of resolutions include any form of relief. **75.8%** of closures are explanation-only, and 1 in 5 of those consumers comes back to dispute it. Speed is not a proxy for quality.

### Insight 5 - Dispute Rates Are Highest in Mortgage, Consumer Loans, and Credit Cards

Among the pre-2017 population (the only period with dispute data), the overall dispute rate is **19.3%**. Mortgage runs at 22.6%, Consumer Loan at 21.4%, and Credit Card at 20.4%.

### Insight 6 - Channel Mix Is Overwhelmingly Digital

Web submissions account for **~85% of intake volume** and the share is still growing. The web form is effectively the entire complaint process, its UX and triage logic are the first and most impactful point of intervention.

## AI/ML Applications

### Dispute Risk Classifier

**Business question:** Can we predict which complaints are likely to be disputed before the company responds?

- **Model:** Random Forest (200 estimators, `max_depth=15`, `class_weight='balanced'`)
- **Training population:** Pre-April 2017 complaints only (the period with CFPB dispute outcome data)
- **Features:** Product, Issue, State, company tier, submission channel (one-hot encoded)
- **Target:** `is_disputed` (binary)
- **Evaluation:** Accuracy, classification report, ROC-AUC
- **Business impact:** Routing high-risk complaints to deeper review before the company responds could prevent disputes at the source, a 10% reduction in disputes equals ~15,000 fewer adverse events over a comparable period

### Untimely Response Predictor

**Business question:** Can we predict which complaints are at risk of missing the CFPB's 15-day deadline?

- **Model:** Random Forest (full dataset, this label is always populated, unlike dispute data)
- **Features:** Company tier, Product, State, submission channel
- **Target:** `is_untimely` (binary)
- **Business impact:** Enables proactive queue prioritization at companies most likely to miss the deadline, particularly Tier 3 operators where the untimely rate is 9.5×

## Recommendations

**Analytics & Measurement**
1. Track **relief rate** as the primary resolution KPI, not just timely-response rate. The system is already fast; depth is the gap.
2. Build a **Bureau Accountability Scorecard** covering untimely rate, dispute rate, and monetary relief rate across the three credit bureaus.

**Machine Learning**
3. Deploy the **Dispute Risk Classifier** on the explanation-only population to flag high-risk closures before they escalate.
4. Deploy the **Untimely Response Predictor** as a prioritization layer for incoming queues.

**Data Engineering**
5. Move product/issue taxonomy to a **dimension table** so renames (like the 2017 "Credit Reporting" label change) don't break downstream metrics.
6. **Migrate to Spark or Databricks** before the dataset doubles, 1.6 GB in pandas is already fragile for a scheduled pipeline.

**Customer Experience**
7. Apply **NLP triage** on the ~30% of complaints with consumer narratives. Classify by severity and route high-risk cases to a remediation team.

## Roadmap

**Short-term (0?3 months)**
- Automate ETL from the CFPB public API ? cleaned warehouse table (daily incremental)
- Build a Tableau/Power BI compliance dashboard
- Standardize company-name fuzzy matching (5,275 raw names, clean entity table)

**Medium-term (3?12 months)**
- Train and deploy the dispute-risk classifier
- Migrate from CSV + pandas to Spark / Databricks
- NLP topic models on consented consumer narratives

**Long-term (12+ months)**
- Near-real-time intake monitoring with anomaly detection (catch Equifax-style spikes in hours, not months)
- ML-driven resolution-quality scoring at company × product × geography

## Key Metrics at a Glance

| Metric | Value |
|---|---|
| Total complaints | 1,284,187 |
| Unique companies | 5,275 |
| Date range | Dec 2011 ? May 2019 |
| Top 10 company share | ~52% |
| Credit bureaus (Big 3) share | ~25% |
| Timely response rate | 97.5% |
| Any-relief outcome rate | 18.6% |
| Monetary-relief outcome rate | 5.8% |
| Explanation-only rate | 75.8% |
| Consumer dispute rate (pre-2017) | 19.3% |
| Web channel share | ~85% |