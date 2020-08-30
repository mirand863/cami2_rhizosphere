#!/usr/bin/env python3
import os, sys, pickle, gzip, shutil

file_gnn_in = sys.argv[1]
output_file = sys.argv[2]

gnn = pickle.load(gzip.open(file_gnn_in, 'rb'))

seqinfo = {}
use_assembly=False
for entry in gnn["bins"]:
	fields = entry.split("\t")

	# assembly field always at the end or empty
	if gnn["rank"]=="assembly":
		use_assembly=True
		assembly = fields.pop(3)
		fields.append(assembly)
	else:
		fields.append("")

	# store fragment always, not with id
	if gnn["fragment_length"]>0:
		uid = fields.pop(0)
		i, pos = uid.split("/")
		st, en = pos.split(":")
		fields.insert(0, i)
		fields.insert(1, st)
		fields.insert(2, en)
	else:
		l = fields[1]
		fields.insert(1, "1")
		fields.insert(2, l)

	seqid=fields[0] 
	if seqid not in seqinfo: seqinfo[seqid] = {"len": 0, "taxid": "", "assembly": ""} 
	seqinfo[seqid]["len"]+=int(fields[3])
	seqinfo[seqid]["taxid"]=fields[4]
	seqinfo[seqid]["assembly"]=fields[6]
	
with open(output_file, "w") as ouf:
	for seqid, d in seqinfo.items():
		if use_assembly:
			print(seqid, d["len"], d["taxid"], d["assembly"], sep="\t", file=ouf)
		else:
			print(seqid, d["len"], d["taxid"], sep="\t", file=ouf)
