import json
from collections import Counter
import copy

rel_clusters=json.load(open('/Users/jason.wu/myproject/try_ke_models/clusters/Reverb-15M_train_clusters.json'))

rel_n_ids = {}
with open('/Users/jason.wu/myproject/try_ke_models/clusters/relation2id.txt') as f:
    # Skip the first line
    f.readline()
    for line in f:
        rel_n,rel_id = line.split('\t')
        rel_id = int(rel_id)
        rel_n_ids.update({rel_n:rel_id})

rel_clusters_id = []
rel_clusters_id_sorted = []
for cluster in rel_clusters:
    cluster_id = []
    for rel in cluster:
        if rel in rel_n_ids:
            cluster_id += [rel_n_ids[rel]]
        else:
            print(rel)
    rel_clusters_id += [cluster_id]
    cluster_id_sorted = copy.copy(cluster_id)
    
    # Sort the relation id
    cluster_id_sorted.sort()
    rel_clusters_id_sorted += [cluster_id_sorted]

json.dump(rel_clusters_id,open('/Users/jason.wu/myproject/try_ke_models/clusters/Reverb-15M_train_clusters_id.json','w'))
json.dump(rel_clusters_id_sorted,open('/Users/jason.wu/myproject/try_ke_models/clusters/Reverb-15M_train_clusters_id_sorted.json','w'))
