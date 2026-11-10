"""Reproducible evaluation of coursework implementations; run from repository root."""
import argparse
import json
from pathlib import Path
import numpy as np
from sklearn.datasets import load_iris, load_digits
from sklearn.metrics import accuracy_score, roc_auc_score
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.multiclass import OneVsRestClassifier
from sklearn.semi_supervised import LabelPropagation
from .svm import DuoFenLeiSVM
from .trees import MyTree, MyForest
from .self_training import self_training

def svm_experiment():
    X, y = load_iris(return_X_y=True)
    Xtr, Xte, ytr, yte = train_test_split(X, y, test_size=.2, stratify=y, random_state=42)
    scores = []
    for C in [1., 10.]:
        for gamma in [.01, .1]:
            acc = []
            for tr, va in StratifiedKFold(3, shuffle=True, random_state=42).split(Xtr,ytr):
                scaler = StandardScaler().fit(Xtr[tr])
                model = DuoFenLeiSVM(C=C,gamma=gamma,max_iter=200)
                model.fit(scaler.transform(Xtr[tr]),ytr[tr])
                acc.append(accuracy_score(ytr[va],model.predict(scaler.transform(Xtr[va]))))
            scores.append({'C':C,'gamma':gamma,'validation_accuracy':float(np.mean(acc))})
    best = max(scores,key=lambda s:s['validation_accuracy'])
    scaler = StandardScaler().fit(Xtr)
    model = DuoFenLeiSVM(C=best['C'],gamma=best['gamma'],max_iter=200)
    model.fit(scaler.transform(Xtr),ytr)
    return {'training_rows':len(ytr),'test_rows':len(yte),'selection':scores,'selected':best,
            'test_accuracy':accuracy_score(yte,model.predict(scaler.transform(Xte)))}

def tree_experiment():
    X,y = load_iris(return_X_y=True)
    result = {}
    # The coursework forest averages bootstrap trees; it does not subsample features.
    for name, factory in [('information_gain',lambda:MyTree()),('gain_ratio',lambda:MyTree(criterion='gain_ratio')),
                          ('bagged_trees',lambda:MyForest())]:
        folds=[]
        for i,(tr,te) in enumerate(StratifiedKFold(5,shuffle=True,random_state=42).split(X,y)):
            np.random.seed(42+i)
            model=factory();model.fit(X[tr],y[tr]);prob=model.predict_proba(X[te])
            folds.append({'accuracy':accuracy_score(y[te],model.predict(X[te])),
                          'macro_auc':roc_auc_score(y[te],prob,multi_class='ovr')})
        result[name]={'folds':folds,'mean_accuracy':float(np.mean([r['accuracy'] for r in folds]))}
    return result

def semi_experiment():
    X,y=load_digits(return_X_y=True)
    Xtr,Xte,ytr,yte=train_test_split(X,y,test_size=.2,stratify=y,random_state=42)
    scaler=StandardScaler().fit(Xtr);Xtr=scaler.transform(Xtr);Xte=scaler.transform(Xte)
    output=[]
    def logistic():return OneVsRestClassifier(LogisticRegression(max_iter=1000,random_state=42))
    for ratio in [.05,.1,.2,.3]:
        labeled,unlabeled=train_test_split(np.arange(len(ytr)),train_size=ratio,stratify=ytr,random_state=42)
        supervised=logistic().fit(Xtr[labeled],ytr[labeled])
        st=self_training(Xtr[labeled],ytr[labeled],Xtr[unlabeled],logistic(),max_iter=20,threshold=.8)
        masked=np.full(len(ytr),-1);masked[labeled]=ytr[labeled]
        lp=LabelPropagation(kernel='knn',n_neighbors=7,max_iter=100).fit(Xtr,masked)
        row={'labeled_fraction':ratio,'labeled_rows':len(labeled)}
        for name,model in [('supervised',supervised),('self_training',st),('label_propagation',lp)]:
            row[name]={'accuracy':accuracy_score(yte,model.predict(Xte)),
                       'macro_auc':roc_auc_score(yte,model.predict_proba(Xte),multi_class='ovr')}
        output.append(row)
    return output

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('experiment',choices=['svm','trees','semi']);p.add_argument('--output',type=Path,required=True)
    args=p.parse_args();result={'experiment':args.experiment,'seed':42,'results':{'svm':svm_experiment,'trees':tree_experiment,'semi':semi_experiment}[args.experiment]()}
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(json.dumps(result,indent=2),encoding='utf8')
    print(json.dumps(result,indent=2))
