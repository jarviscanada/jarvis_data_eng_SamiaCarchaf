# Home Credit Default Risk — Capstone (Module 1)

End-to-end credit scoring system built on the Kaggle [Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk/data) dataset.

## Project Structure

```
capstone/
├── data/               ← raw CSV files (not version-controlled, see .gitignore)
├── notebooks/
│   ├── 01_eda.ipynb                 ← exploration & visualization
│   ├── 02_preprocessing.ipynb       ← missing value handling, sentinel values
│   ├── 03_feature_engineering.ipynb ← features, encoding, segmentation (K-Means)
│   ├── 04_modeling.ipynb            ← training, comparison, tuning
│   ├── 05_explainability.ipynb      ← SHAP, adverse action, PSI, monitoring
│   ├── 06_final_pipeline.ipynb      ← production pipeline (raw data → prediction)
│   └── 07_live_demo.ipynb           ← standalone demo for the final presentation
├── figs/               ← generated figures (EDA, SHAP, ROC/PR curves, segments)
├── models/
│   ├── best_model.pkl                 ← final model (engineered features), AUROC 0.7678
│   ├── credit_scoring_pipeline.pkl    ← production pipeline (raw data), AUROC 0.7584
│   ├── shap_values_pos.npy            ← saved SHAP values (1,000-sample explainer set)
│   └── shap_sample.csv                ← corresponding sample data
├── reports/
│   └── model_documentation.md ← model validation summary (SR 11-7 format)
└── requirements.txt
```

## Setup

1. Create and activate a virtual environment (Python 3.10):

```bash
python3.10 -m venv venv
source venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

3. Download the 7 competition CSV files from the Kaggle page and place them in `data/`:
   * application_train.csv
   * bureau.csv
   * bureau_balance.csv
   * credit_card_balance.csv
   * installments_payments.csv
   * POS_CASH_balance.csv
   * previous_application.csv

   *(Only `application_train.csv` and `bureau.csv` are used in this iteration of the project — the rest are included for future reference.)*

4. Verify the setup: open `notebooks/01_eda.ipynb` and confirm `application_train.csv` loads with the expected shape (~307,511 rows, 122 columns).

## Reproducing the Results

Run the notebooks in order (01 → 06):

1. **01_eda** → exploration, sentinel-value detection, class imbalance
2. **02_preprocessing** → missing-value handling, saves `preprocessed_train.csv`
3. **03_feature_engineering** → financial ratios, bureau aggregations, customer segmentation, saves `final_train.csv`
4. **04_modeling** → compares 3 models, tuning, saves `models/best_model.pkl`
5. **05_explainability** → SHAP, adverse action notice, fairness test, PSI, saves SHAP artifacts
6. **06_final_pipeline** → full raw-data pipeline, saves `models/credit_scoring_pipeline.pkl`

**07_live_demo** is standalone (doesn't require re-running the other notebooks in the same session) and serves as a quick demonstration for the final presentation, it simply reloads the already-saved pipeline and predicts on one real raw row from the test set.

## Loading and Using the Final Model

```python
import joblib
import pandas as pd

pipeline = joblib.load('models/credit_scoring_pipeline.pkl')

# raw_applicant_df: DataFrame with the raw columns from application_train.csv (excluding TARGET and SK_ID_CURR)
predicted_probability = pipeline.predict_proba(raw_applicant_df)[:, 1]
```

## Performance Target

AUROC ≥ 0.72 on the test set — **achieved: 0.7678** (final feature-engineered model) / **0.7584** (raw-data production pipeline).

See `reports/model_documentation.md` for the full metrics breakdown, explainability analysis, known limitations, and monitoring plan.
