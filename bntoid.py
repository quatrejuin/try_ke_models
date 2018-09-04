from sklearn.model_selection import train_test_split

def write_triple_file(triples,file):
    with open(file,"w") as f3:
        f.write("{}\n".format(len(triples)))
        for t in triples:
            arg1,arg2,rel = t
            f.write("{}\t{}\t{}\n".format(arg1,arg2,rel))

# Triples file in DeFIE download link http://lcl.uniroma1.it/defie/data/defie_KB_bn2.5.1.zip
in_file_path = "/Users/jason.wu/Desktop/2018summer/defie_KB_bn2/definitions_bn2.5/bn2.5_10.triples.tsv"
out_path = "/Users/jason.wu/myproject/OpenKE/data/defie/"
bn2id_file_path = out_path+"bn2id_all.txt"
train2id_file_path = out_path+"train2id.txt"
valid2id_file_path = out_path+"valid2id.txt"
test2id_file_path = out_path+"test2id.txt"
entity2id_file_path = out_path+"entity2id.txt"
relation2id_file_path = out_path+"relation2id.txt"

# Open file
with open(in_file_path) as file:
    lines = file.readlines()
    
# bn2id_all.txt    
bn_ids = {}
bn2id_list = []
bn2id_file_content = ''
for index,l in enumerate(lines):
    if index%10**6 == 0:
        print("index={} million".format(int(index/10**6)))
    arg1, r, arg2 = l.split('\t')
    r= int(r)
    arg1= arg1.strip()
    arg2= arg2.strip()
    if arg1 not in bn_ids:
        bn_ids.update({arg1:len(bn_ids)})
    if arg2 not in bn_ids:
        bn_ids.update({arg2:len(bn_ids)})
    #bn2id_file_content += "{}\t{}\t{}\n".format(bn_ids[arg1],bn_ids[arg2],r)
    bn2id_list += [(bn_ids[arg1],bn_ids[arg2],r)]


# Add the first line
train_file_content = "{}\n{}".format(len(lines),train_file_content)
# Write
write_triple_file(bn2id_list, bn2id_file_path)

# Split train, valid, test file
train, test = train_test_split(bn2id_list, test_size=0.1)
train, valid = train_test_split(train, test_size=0.1)

# Write train2id.txt, valid2id.txt, test2id.txt
write_triple_file(train, train2id_file_path)
write_triple_file(valid, valid2id_file_path)
write_triple_file(test, test2id_file_path)

# entity2id.txt
entity2id_file_content = ''
for e in bn_ids:
    entity2id_file_content +=  "{}\t{}\n".format(e,bn_ids[e])

# Add the first line
entity2id_file_content = "{}\n{}".format(len(bn_ids),entity2id_file_content)
# Write
open(entity2id_file_path, 'w').write(entity2id_file_content)

# Create dummy relation file relation2id.txt
relation2id_file_content = ''
rel_n = 255881
for i in range(0,rel_n):
    relation2id_file_content +=  "rel{0}\t{0}\n".format(i)
relation2id_file_content = "{}\n{}".format(rel_n,relation2id_file_content)
open(relation2id_file_path, 'w').write(relation2id_file_content)