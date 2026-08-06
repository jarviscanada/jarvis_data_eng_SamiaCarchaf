# Home Credit Default Risk — Capstone (Module 1)

Système de scoring de crédit end-to-end construit sur le dataset Kaggle
[Home Credit Default Risk](https://www.kaggle.com/c/home-credit-default-risk/data).

## Structure du projet

```
capstone/
├── data/               ← fichiers CSV bruts (non versionnés, voir .gitignore)
├── notebooks/
│   ├── 01_eda.ipynb                 ← exploration & visualisation
│   ├── 02_preprocessing.ipynb       ← gestion des valeurs manquantes, sentinelles
│   ├── 03_feature_engineering.ipynb ← features, encodage, clustering
│   ├── 04_modeling.ipynb            ← entraînement, comparaison, tuning
│   └── 05_explainability.ipynb      ← SHAP, adverse action, PSI
├── src/                ← fonctions Python réutilisables
├── models/             ← pipelines sauvegardés (.pkl)
├── reports/            ← model_documentation.md (SR 11-7)
└── requirements.txt
```

## Setup

1. Créer et activer un environnement virtuel (Python 3.9+) :
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

2. Installer les dépendances :
   ```bash
   pip install -r requirements.txt
   ```

3. Télécharger les 7 fichiers CSV depuis la page Kaggle du concours et les
   placer dans `data/` :
   - application_train.csv
   - bureau.csv
   - bureau_balance.csv
   - credit_card_balance.csv
   - installments_payments.csv
   - POS_CASH_balance.csv
   - previous_application.csv

4. Vérifier le setup : ouvrir `notebooks/01_eda.ipynb` et confirmer que
   `application_train.csv` charge avec la forme attendue
   (~307 511 lignes, 122 colonnes).

## Reproduire les résultats

Exécuter les notebooks dans l'ordre (01 → 05). Le pipeline final entraîné
est sauvegardé dans `models/credit_scoring_pipeline.pkl` et peut être
rechargé avec `joblib.load(...)`.

## Objectif de performance

AUROC ≥ 0.72 sur le test set (voir `reports/model_documentation.md` pour
le détail des métriques).
