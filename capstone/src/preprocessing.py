"""
Fonctions de preprocessing réutilisables pour le pipeline Home Credit.
"""
import numpy as np
import pandas as pd


def handle_missing(df: pd.DataFrame) -> pd.DataFrame:
    """
    Gère les valeurs sentinelles et manquantes.
    - DAYS_EMPLOYED == 365243 -> NaN (sentinelle 'sans emploi/retraité')
    """
    df = df.copy()
    if "DAYS_EMPLOYED" in df.columns:
        df["DAYS_EMPLOYED"] = df["DAYS_EMPLOYED"].replace(365243, np.nan)
    return df


def engineer_features(df: pd.DataFrame) -> pd.DataFrame:
    """
    Crée les features de risque crédit standards (ratios, EXT_SOURCE agrégés, etc.).
    À compléter à l'étape 2 du capstone.
    """
    df = df.copy()
    # TODO: CREDIT_INCOME_RATIO, ANNUITY_INCOME_RATIO, CREDIT_TERM,
    # DAYS_EMPLOYED_RATIO, INCOME_PER_PERSON, EXT_SOURCE_MEAN, EXT_SOURCE_STD, AGE_BUCKET
    return df


def encode_categoricals(df: pd.DataFrame) -> pd.DataFrame:
    """
    Encode les variables catégorielles (ordinal / one-hot / fréquence).
    À compléter à l'étape 2 du capstone.
    """
    df = df.copy()
    return df
