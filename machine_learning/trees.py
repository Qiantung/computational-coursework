import numpy as np


from sklearn.datasets import load_iris


from sklearn.model_selection import KFold


from sklearn.metrics import accuracy_score, roc_auc_score


from sklearn.preprocessing import LabelBinarizer


def entropy(y):
    """计算熵"""
    vals, cnts = np.unique(y, return_counts=True)
    p = cnts / len(y)
    return -np.sum(p * np.log2(p + 1e-10))


def info_gain(y, left, right):
    """计算信息增益"""
    h = entropy(y)
    h_l = entropy(left)
    h_r = entropy(right)
    w_l = len(left) / len(y)
    w_r = len(right) / len(y)
    return h - (w_l * h_l + w_r * h_r)


def split_info(left, right):
    """计算分割信息"""
    total = len(left) + len(right)
    p1 = len(left) / total
    p2 = len(right) / total
    if p1 <= 0 or p2 <= 0:
        return 1e-10
    return -(p1 * np.log2(p1) + p2 * np.log2(p2))


def gain_ratio(y, left, right):
    """计算增益率 = 信息增益 / 分割信息"""
    ig = info_gain(y, left, right)
    si = split_info(left, right)
    if si == 0:
        return 0.0
    return ig / si


def best_split(X, y, criterion="info_gain"):
    """找最优分裂：返回特征索引和阈值"""
    best_score = -np.inf
    best_feat = None
    best_thresh = None
    n_feat = X.shape[1]

    for f in range(n_feat):
        sorted_vals = np.sort(np.unique(X[:, f]))
        for i in range(len(sorted_vals) - 1):
            t = (sorted_vals[i] + sorted_vals[i + 1]) / 2
            mask_l = X[:, f] <= t
            mask_r = X[:, f] > t
            yl, yr = y[mask_l], y[mask_r]
            
            if len(yl) == 0 or len(yr) == 0:
                continue

            # 根据准则选择分裂方式
            if criterion == "info_gain":
                score = info_gain(y, yl, yr)
            else:  # gain_ratio
                score = gain_ratio(y, yl, yr)

            if score > best_score:
                best_score = score
                best_feat = f
                best_thresh = t

    return best_feat, best_thresh


class MyTree:
    def __init__(self, criterion="info_gain", max_depth=3, min_samples_split=2):
        self.criterion = criterion
        self.max_depth = max_depth
        self.min_samples_split = min_samples_split
        self.root = None
        self.n_classes = 3

    def build(self, X, y, depth=0):
        """递归构建决策树"""
        counts = np.bincount(y, minlength=self.n_classes)
        probs = counts / len(y)

        # 停止条件
        if len(np.unique(y)) == 1 or depth >= self.max_depth or len(y) < self.min_samples_split:
            return {"leaf": True, "probs": probs}

        feat, thresh = best_split(X, y, self.criterion)
        if feat is None:
            return {"leaf": True, "probs": probs}

        mask_l = X[:, feat] <= thresh
        mask_r = X[:, feat] > thresh

        left = self.build(X[mask_l], y[mask_l], depth + 1)
        right = self.build(X[mask_r], y[mask_r], depth + 1)

        return {
            "leaf": False,
            "feat": feat,
            "thresh": round(thresh, 4),
            "left": left,
            "right": right
        }

    def fit(self, X, y):
        """训练模型"""
        self.n_classes = len(np.unique(y))
        self.root = self.build(X, y)

    def _proba(self, x, node):
        """递归预测概率"""
        if node["leaf"]:
            return node["probs"]
        if x[node["feat"]] <= node["thresh"]:
            return self._proba(x, node["left"])
        else:
            return self._proba(x, node["right"])

    def predict_proba(self, X):
        """预测概率"""
        return np.array([self._proba(x, self.root) for x in X])

    def predict(self, X):
        """预测类别"""
        return np.argmax(self.predict_proba(X), axis=1)


class MyForest:
    def __init__(self, n_estimators=10, max_depth=3):
        self.n_estimators = n_estimators
        self.max_depth = max_depth
        self.trees = []

    def fit(self, X, y):
        """使用Bootstrap采样训练多个决策树"""
        self.trees = []
        for _ in range(self.n_estimators):
            # Bootstrap采样
            idx = np.random.choice(len(X), len(X), replace=True)
            tx, ty = X[idx], y[idx]
            
            # 训练基学习器（使用信息增益）
            t = MyTree(criterion="info_gain", max_depth=self.max_depth)
            t.fit(tx, ty)
            self.trees.append(t)

    def predict_proba(self, X):
        """对所有树的概率进行平均"""
        return np.mean([t.predict_proba(X) for t in self.trees], axis=0)

    def predict(self, X):
        """预测类别"""
        return np.argmax(self.predict_proba(X), axis=1)


