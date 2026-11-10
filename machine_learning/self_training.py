import numpy as np


from sklearn.datasets import load_digits


from sklearn.model_selection import train_test_split


from sklearn.preprocessing import StandardScaler


from sklearn.linear_model import LogisticRegression


from sklearn.semi_supervised import LabelPropagation


from sklearn.metrics import accuracy_score, roc_auc_score


import warnings


def self_training(X_labeled, y_labeled, X_unlabeled, base_classifier, max_iter=10, threshold=0.9):
    X_labeled = X_labeled.copy()
    y_labeled = y_labeled.copy()
    X_unlabeled = X_unlabeled.copy()
    clf = base_classifier
    for _ in range(max_iter):
        if len(X_unlabeled) == 0:
            break
        clf.fit(X_labeled, y_labeled)
        proba = clf.predict_proba(X_unlabeled)
        conf = np.max(proba, axis=1)
        high_conf_idx = conf >= threshold
        if not np.any(high_conf_idx):
            break
        X_add = X_unlabeled[high_conf_idx]
        y_add = clf.predict(X_add)
        X_labeled = np.vstack([X_labeled, X_add])
        y_labeled = np.hstack([y_labeled, y_add])
        X_unlabeled = X_unlabeled[~high_conf_idx]
    clf.fit(X_labeled, y_labeled)
    return clf


