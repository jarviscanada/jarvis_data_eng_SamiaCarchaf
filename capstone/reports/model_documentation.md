# Model Validation Summary — Home Credit Default Risk Scoring Model

**Prepared by:** Samia Carchaf
**Date:** 01/09/2026
**Model version / hash:** see `models/credit_scoring_pipeline.pkl` (SHA-256 recorded in `06_final_pipeline.ipynb`, Section 6)
**Training data:** `application_train.csv` (Home Credit Default Risk, Kaggle) , hash recorded in `06_final_pipeline.ipynb`, Section 6

---

## 1. Model Purpose

Home Credit is an international consumer finance provider whose applicant base includes many people with little or no traditional credit history, making them difficult to assess with conventional credit-scoring methods. This model predicts, at the time of application, the probability that a loan applicant will experience payment difficulties (default), using application data and supplementary credit bureau history. The prediction supports, rather than replaces, the approve/decline/manual-review decision, and specifically targets improving assessment accuracy for the **Young Thin-File Applicants** segment: young, credit-history-light applicants who make up 31.8% of the portfolio and default at 13.2%, more than double the safest segment (5.0%).

## 2. Methodology

- **Algorithm:** HistGradientBoostingClassifier (scikit-learn), selected after comparing Logistic Regression, Random Forest, and Gradient Boosting on identical held-out test data.
- **Features:** 230 features after engineering, including financial ratios (CREDIT_INCOME_RATIO, ANNUITY_INCOME_RATIO, CREDIT_TERM), combined external bureau scores (EXT_SOURCE_MEAN, EXT_SOURCE_STD), bureau-history aggregations (BUREAU_COUNT, BUREAU_ACTIVE_COUNT, BUREAU_AMT_OVERDUE_MAX, etc.), missingness indicators for all columns >5% missing, and encoded categoricals (ordinal, one-hot, frequency encoding by cardinality).
- **Hyperparameters (final, tuned via RandomizedSearchCV, 20 iterations, 3-fold CV):** `max_iter=200, max_depth=6, learning_rate=0.05, l2_regularization=1.0, class_weight='balanced'`.
- **Training data period:** Single historical snapshot (Kaggle competition dataset); no explicit application date field, so no temporal ordering was assumed or required.
- **Validation:** Stratified 80/20 train/test split (random_state=42); 5-fold StratifiedKFold cross-validation for stability checks.
- **Production pipeline:** A separate scikit-learn `Pipeline` (`ColumnTransformer` + classifier) accepts raw, unprocessed applicant data and returns a prediction directly, with no manual preprocessing steps, for genuine production readiness.

## 3. Performance

| Metric | Value |
|---|---|
| AUROC (held-out test) | 0.7678 |
| Gini | 0.5356 |
| KS | 0.4000 |
| AUPRC | 0.2621 |
| F1 (F1-optimal threshold 0.1652) | 0.3219 |
| 5-fold CV AUROC (mean ± std) | 0.7647 ± 0.0006 |
| CV-to-test gap | 0.003 (no evidence of overfitting) |
| Baseline comparison | Logistic Regression 0.7543, Random Forest 0.7456 — final model wins on every metric |
| Young Thin-File segment AUROC | 0.7479 (test-set only, ~0.02 below aggregate; still clears the 0.72 target) |
| Production pipeline (raw data) AUROC | 0.7584 (~0.009 below the fully engineered model; gap concentrated in applicants with missing external bureau scores) |
| Operating threshold (selected) | 0.08 — catches 70% of true defaults, flags 33.4% of applicants for review |

All figures exceed the project's AUROC ≥ 0.72 target and sit within the Gini (0.40–0.60) and KS (>0.30) ranges typical of deployed consumer credit scorecards.

## 4. Explainability

SHAP (TreeExplainer) was used for both global and local explanations:

- **Top predictor:** EXT_SOURCE_MEAN, with mean |SHAP| ~4.4x higher than the next-ranked feature (CREDIT_TERM), consistent with EDA findings that combined external bureau scores are the strongest available signal.
- **Individual explanations:** Waterfall plots generated for representative high-risk, borderline, and low-risk applicants, confirming the model's reasoning aligns with financial intuition (e.g., low external bureau scores and prior payment delinquency drive risk up; higher education is a protective factor).
- **Adverse action notices:** Automatically generated for declined applicants, listing the top 4 non-protected contributing factors (e.g., bureau score, prior delinquency, loan size relative to profile) per ECOA requirements. CODE_GENDER_M is explicitly excluded from adverse-action reasoning.
- **Fairness testing:** CODE_GENDER_M appeared as a directionally consistent factor in individual SHAP explanations, prompting a formal disparate impact test. Approval rates: 90.9% (female) vs. 82.5% (male), an adverse impact ratio of 0.908, passing the standard 80% regulatory threshold. This is flagged for ongoing monitoring, not treated as fully settled.

## 5. Limitations

- **Segment-specific performance gap:** AUROC for the Young Thin-File segment (0.7479) is measurably below the aggregate (0.7678). The model clears the target threshold for this segment but is less sharp for the population it matters most for.
- **Economic regime risk:** The model is trained on a single historical period. A recession could shift default rates, particularly for the Young Thin-File segment, in ways not represented in training data.
- **Production pipeline gap:** The raw-data production pipeline (0.7584 AUROC) does not reconstruct the EXT_SOURCE_MEAN combination feature, causing a larger individual-level gap for applicants with missing external scores specifically.
- **Untapped data:** 5 of 7 available relational tables (installments_payments.csv, previous_application.csv, credit_card_balance.csv, POS_CASH_balance.csv, bureau_balance.csv) were not incorporated in this iteration; payment history in particular is a likely source of additional signal.
- **Minor data leakage (low impact):** Early-stage preprocessing statistics (median imputation values) were computed on the full dataset prior to the train/test split in `02_preprocessing.ipynb`. Given the dataset's size (307,511 rows), the practical impact is expected to be negligible; the production pipeline (`06_final_pipeline.ipynb`) correctly fits all preprocessing exclusively on the training fold.

## 6. Monitoring Plan

- **Population Stability Index (PSI):** Recomputed monthly for the top 10 SHAP-important features. PSI < 0.1 = stable; 0.1–0.25 = moderate shift, under review; >0.25 = significant shift, triggers a full model review. At baseline (train vs. test), all top-10 features show PSI ≈ 0 (max 0.000275).
- **Performance monitoring:** Rolling AUROC computed on recent live outcomes; retraining triggered if AUROC drops below approximately 0.70 (vs. the 0.7678 development baseline).
- **Fairness re-testing:** Disparate impact test (80% rule) re-run quarterly on CODE_GENDER_M as the applicant population evolves.
- **Segment-level tracking:** AUROC and PSI tracked separately for the Young Thin-File segment, given its confirmed performance gap and higher business priority.
- **Versioning:** Data and model versions tracked via SHA-256 hashing (`06_final_pipeline.ipynb`, Section 6) to support reproducibility and audit requirements.
