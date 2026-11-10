import unittest
from pathlib import Path
import numpy as np
import pandas as pd
from machine_learning.svm import rbf, RuanJianGeSVM, er_fen_lei_auc
from economic_data.gdp_analysis import analyze
from vision.cowface import make_pairs

class CourseworkChecks(unittest.TestCase):
    def test_auc_ties(self):
        self.assertEqual(er_fen_lei_auc(np.array([1,-1,1,-1]),np.ones(4)),.5)
    def test_kernel_and_separation(self):
        X=np.array([[-2.,-1.],[-1.,-2.],[1.,2.],[2.,1.]])
        y=np.array([-1,-1,1,1]);K=rbf(X,X,.1)
        np.testing.assert_allclose(K,K.T);np.testing.assert_allclose(np.diag(K),1)
        model=RuanJianGeSVM(C=10,gamma=.1);model.fit(X,y)
        np.testing.assert_array_equal(model.predict(X),y)
    def test_economic_data_validation(self):
        frame=pd.read_csv('economic_data/synthetic_gdp.csv')
        output,summary=analyze(frame);self.assertEqual(len(output),30)
        with self.assertRaises(ValueError):analyze(pd.concat([frame,frame.iloc[:1]]))
        frame.loc[0,'population']=0
        with self.assertRaises(ValueError):analyze(frame)
    def test_pairs_keep_identity_partition(self):
        images={str(i):[Path(f'{i}/a.png'),Path(f'{i}/b.png')] for i in range(8)}
        a,_=make_pairs(list(images)[:4],images,np.random.default_rng(42))
        b,_=make_pairs(list(images)[4:],images,np.random.default_rng(42))
        self.assertFalse({p.parent for pair in a for p in pair}&{p.parent for pair in b for p in pair})

if __name__=='__main__':unittest.main()
