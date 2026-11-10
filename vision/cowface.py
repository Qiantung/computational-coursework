"""ResNet50 pair differences + random forest. Release adaptation of rec2.py.

Images and pretrained weights are external. Download ImageNet weights only when
the user explicitly invokes this training command. No weights are redistributed.
"""
import argparse
import json
from pathlib import Path
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score,roc_auc_score

def make_pairs(ids, images, rng, per_identity=3):
    if len(ids)<2:raise ValueError('Each identity partition requires at least two cows.')
    pairs=[];labels=[]
    for cow in ids:
        for _ in range(per_identity):
            pair=rng.choice(len(images[cow]),size=2,replace=False)
            pairs.append((images[cow][pair[0]],images[cow][pair[1]]));labels.append(1)
    for _ in range(len(labels)):
        a,b=rng.choice(ids,size=2,replace=False)
        pairs.append((images[a][rng.integers(len(images[a]))],images[b][rng.integers(len(images[b]))]));labels.append(0)
    return pairs,np.asarray(labels)

def fit_pair_classifier(Xtrain,ytrain,Xtest,ytest):
    model=RandomForestClassifier(n_estimators=300,n_jobs=-1,random_state=42)
    model.fit(Xtrain,ytrain);prob=model.predict_proba(Xtest)[:,1]
    return {'accuracy':accuracy_score(ytest,model.predict(Xtest)), 'auc':roc_auc_score(ytest,prob),
            'train_pairs':len(ytrain),'test_pairs':len(ytest)}

def train(root):
    import torch
    from torchvision import models,transforms
    from PIL import Image
    images={p.name:sorted([x for x in p.iterdir() if x.suffix.lower() in {'.jpg','.jpeg','.png'}])
            for p in sorted(root.iterdir()) if p.is_dir()}
    images={k:v for k,v in images.items() if len(v)>=2}
    if len(images)<8:raise ValueError('At least eight identities with two images each required.')
    rng=np.random.default_rng(42);ids=np.array(sorted(images));rng.shuffle(ids);n=max(2,int(len(ids)*.2))
    train_ids,test_ids=ids[n:],ids[:n]
    assert not set(train_ids)&set(test_ids)
    # Split identities before pairs to prevent the same cow or photo entering both partitions.
    train_pairs,ytrain=make_pairs(train_ids,images,rng);test_pairs,ytest=make_pairs(test_ids,images,rng)
    device=torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    weights=models.ResNet50_Weights.DEFAULT
    network=models.resnet50(weights=weights);network=torch.nn.Sequential(*list(network.children())[:-1]).to(device).eval()
    transform=weights.transforms();cache={}
    def embedding(path):
        if path not in cache:
            with Image.open(path) as image:batch=transform(image.convert('RGB')).unsqueeze(0).to(device)
            with torch.no_grad():cache[path]=network(batch).flatten().cpu().numpy()
        return cache[path]
    def features(pairs):return np.asarray([np.abs(embedding(a)-embedding(b)) for a,b in pairs])
    result=fit_pair_classifier(features(train_pairs),ytrain,features(test_pairs),ytest)
    result.update(train_identities=len(train_ids),test_identities=len(test_ids),seed=42,
                  limitation='Synthetic pair sampling is not an official challenge evaluation protocol.')
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--images',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    result=train(a.images);a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text(json.dumps(result,indent=2),encoding='utf8')
    print(json.dumps(result,indent=2))
