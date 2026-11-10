import numpy as np


from sklearn.datasets import load_iris


from sklearn.preprocessing import StandardScaler


from sklearn.model_selection import KFold


from sklearn.metrics import accuracy_score


import itertools


def rbf(a1, a2, gamma=0.1):
    if a1.ndim == 1 and a2.ndim == 1:
        return np.exp(-gamma * np.sum((a1 - a2) ** 2))
    elif a1.ndim == 1:
        return np.exp(-gamma * np.sum((a2 - a1) ** 2, axis=1))
    elif a2.ndim == 1:
        return np.exp(-gamma * np.sum((a1 - a2) ** 2, axis=1))
    else:
        ju_li_ping_fang = np.sum(a1**2, axis=1).reshape(-1, 1) + np.sum(a2**2, axis=1) - 2 * np.dot(a1, a2.T)
        return np.exp(-gamma * ju_li_ping_fang)


def er_fen_lei_auc(b_zhen_shi, b_ping_fen):
    """Release fix: give tied scores their correct half credit."""
    from sklearn.metrics import roc_auc_score
    labels = np.where(b_zhen_shi == 1, 1, 0)
    if len(np.unique(labels)) < 2:
        return 0.5
    return float(roc_auc_score(labels, b_ping_fen))


def hong_ping_jun_auc(b_zhen_shi, b_ping_fen, lei_bie):
    aucs = []
    for c, lei_bie_zhi in enumerate(lei_bie):
        b_er_fen_lei = np.where(b_zhen_shi == lei_bie_zhi, 1, -1)
        b_ping_fen_er_fen_lei = b_ping_fen[:, c]
        aucs.append(er_fen_lei_auc(b_er_fen_lei, b_ping_fen_er_fen_lei))
    return np.mean(aucs)


class RuanJianGeSVM:
    def __init__(self, C=1.0, gamma=0.1, max_iter=500, tol=1e-3):
        self.C = C
        self.gamma = gamma
        self.max_iter = max_iter
        self.tol = tol
        self.alpha = None
        self.b = 0
        self.a_xun_lian = None
        self.b_xun_lian = None
        self.zhi_chi_xiang_liang = None
        self.zhi_chi_alpha = None
        self.zhi_chi_y = None

    def fit(self, a, b):
        yang_ben_shu, te_zheng_shu = a.shape
        self.a_xun_lian = a
        self.b_xun_lian = b
        self.alpha = np.zeros(yang_ben_shu)
        self.b = 0

        K = rbf(a, a, self.gamma)

        for _ in range(self.max_iter):
            alpha_prev = self.alpha.copy()
            for c in range(yang_ben_shu):
                g_c = np.sum(self.alpha * b * K[:, c]) + self.b
                E_c = g_c - b[c]

                if (b[c] * E_c < -self.tol and self.alpha[c] < self.C) or \
                   (b[c] * E_c > self.tol and self.alpha[c] > 0):
                    
                    d = self._xuan_ze_d(c, yang_ben_shu, E_c, b, K)
                    if d == c:
                        continue

                    g_d = np.sum(self.alpha * b * K[:, d]) + self.b
                    E_d = g_d - b[d]

                    alpha_c_old, alpha_d_old = self.alpha[c].copy(), self.alpha[d].copy()

                    if b[c] != b[d]:
                        L = max(0, self.alpha[d] - self.alpha[c])
                        H = min(self.C, self.C + self.alpha[d] - self.alpha[c])
                    else:
                        L = max(0, self.alpha[c] + self.alpha[d] - self.C)
                        H = min(self.C, self.alpha[c] + self.alpha[d])
                    if L == H:
                        continue

                    eta = 2 * K[c, d] - K[c, c] - K[d, d]
                    if eta >= 0:
                        continue

                    self.alpha[d] -= b[d] * (E_c - E_d) / eta
                    self.alpha[d] = np.clip(self.alpha[d], L, H)

                    if abs(self.alpha[d] - alpha_d_old) < 1e-5:
                        continue

                    self.alpha[c] += b[c] * b[d] * (alpha_d_old - self.alpha[d])

                    b1 = self.b - E_c - b[c]*(self.alpha[c]-alpha_c_old)*K[c,c] - b[d]*(self.alpha[d]-alpha_d_old)*K[c,d]
                    b2 = self.b - E_d - b[c]*(self.alpha[c]-alpha_c_old)*K[c,d] - b[d]*(self.alpha[d]-alpha_d_old)*K[d,d]
                    if 0 < self.alpha[c] < self.C:
                        self.b = b1
                    elif 0 < self.alpha[d] < self.C:
                        self.b = b2
                    else:
                        self.b = (b1 + b2) / 2

            if np.linalg.norm(self.alpha - alpha_prev) < self.tol:
                break

        zhi_chi_suo_yin = self.alpha > 1e-5
        self.zhi_chi_xiang_liang = a[zhi_chi_suo_yin]
        self.zhi_chi_alpha = self.alpha[zhi_chi_suo_yin]
        self.zhi_chi_y = b[zhi_chi_suo_yin]

    def _xuan_ze_d(self, c, yang_ben_shu, E_c, b, K):
        E = np.zeros(yang_ben_shu)
        for k in range(yang_ben_shu):
            g_k = np.sum(self.alpha * b * K[:, k]) + self.b
            E[k] = g_k - b[k]
        d_ke_xuan = [d for d in range(yang_ben_shu) if d != c]
        return d_ke_xuan[np.argmax(np.abs(E_c - E[d_ke_xuan]))]

    def jue_ce_han_shu(self, a):
        K_zhi_chi = rbf(a, self.zhi_chi_xiang_liang, self.gamma)
        return np.sum(self.zhi_chi_alpha * self.zhi_chi_y * K_zhi_chi, axis=1) + self.b

    def predict(self, a):
        return np.sign(self.jue_ce_han_shu(a))


class DuoFenLeiSVM:
    def __init__(self, C=1.0, gamma=0.1, max_iter=500, tol=1e-3):
        self.C = C
        self.gamma = gamma
        self.max_iter = max_iter
        self.tol = tol
        self.fen_lei_qi = []
        self.lei_bie = None

    def fit(self, a, b):
        self.lei_bie = np.unique(b)
        self.fen_lei_qi = []
        for lei_bie_zhi in self.lei_bie:
            b_er_fen_lei = np.where(b == lei_bie_zhi, 1, -1)
            qi = RuanJianGeSVM(C=self.C, gamma=self.gamma, max_iter=self.max_iter, tol=self.tol)
            qi.fit(a, b_er_fen_lei)
            self.fen_lei_qi.append(qi)

    def predict(self, a):
        b_ping_fen = np.zeros((a.shape[0], len(self.lei_bie)))
        for c, qi in enumerate(self.fen_lei_qi):
            b_ping_fen[:, c] = qi.jue_ce_han_shu(a)
        return self.lei_bie[np.argmax(b_ping_fen, axis=1)]

    def jue_ce_han_shu(self, a):
        b_ping_fen = np.zeros((a.shape[0], len(self.lei_bie)))
        for c, qi in enumerate(self.fen_lei_qi):
            b_ping_fen[:, c] = qi.jue_ce_han_shu(a)
        return b_ping_fen


