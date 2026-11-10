"""Release adaptation of GDP coursework: descriptive clustering, not causal inference."""
import argparse
import json
from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score

def analyze(frame):
    required=['country','year','gdp_usd','population']
    if not set(required)<=set(frame):raise ValueError(f'Required columns: {required}')
    df=frame[required].copy()
    for col in ['year','gdp_usd','population']:df[col]=pd.to_numeric(df[col],errors='coerce')
    if df.isna().any().any() or (df[['gdp_usd','population']]<=0).any().any():
        raise ValueError('Missing, nonnumeric or nonpositive economic inputs; correct them explicitly.')
    if not np.isfinite(df[['year','gdp_usd','population']].to_numpy()).all():raise ValueError('Nonfinite inputs')
    if df['year'].nunique()!=1:raise ValueError('Use one common year; do not pool years as countries.')
    if df['country'].duplicated().any():raise ValueError('Duplicate country-year observations')
    if len(df)<6:raise ValueError('At least six countries are needed for this demo.')
    df['gdp_per_capita_usd']=df.gdp_usd/df.population
    features=StandardScaler().fit_transform(np.log(df[['gdp_usd','gdp_per_capita_usd']]))
    candidates=[];models={}
    for k in range(2,min(5,len(df)-1)+1):
        model=KMeans(n_clusters=k,n_init=10,random_state=42).fit(features)
        if len(np.unique(model.labels_))!=k:continue
        candidates.append({'k':k,'silhouette':float(silhouette_score(features,model.labels_))});models[k]=model
    if not candidates:raise ValueError('Insufficient distinct observations for clustering')
    best=max(candidates,key=lambda r:r['silhouette']);df['cluster']=models[best['k']].labels_
    return df,{'rows':len(df),'year':int(df.year.iloc[0]),'selected':best,'candidates':candidates,
               'interpretation':'Descriptive clusters; labels have no ordinal meaning and are not economic development grades.'}

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--input',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    df,summary=analyze(pd.read_csv(a.input));a.output.mkdir(parents=True,exist_ok=True)
    df.to_csv(a.output/'clusters.csv',index=False);(a.output/'summary.json').write_text(json.dumps(summary,indent=2),encoding='utf8')
    print(json.dumps(summary,indent=2))
