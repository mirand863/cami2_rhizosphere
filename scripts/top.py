#!/usr/bin/env python3

import pandas as pd
import argparse

parser = argparse.ArgumentParser(description='Extracts the top n assemblies for each taxid')
parser.add_argument('--top', type=int, default=3, help='Number of top assemblies to be extracted')
parser.add_argument('input', type=str, help='Input file in the format accession.version <tab> length <tab> taxid <tab> assembly accession')
parser.add_argument('output', type=str, help='Output file containing top assemblies')
args = parser.parse_args()

seqinfo = pd.read_csv(args.input, sep='\t', header=None)
labels = ['accession_version', 'length', 'taxid', 'assembly_accession']
seqinfo.columns = labels
for taxid in seqinfo.loc[:, 'taxid'].unique():
    query_taxid = seqinfo.loc[seqinfo.loc[:, 'taxid'] == taxid]
    unique_assemblies = query_taxid.loc[:, 'assembly_accession'].unique()
    assemblies_lengths = []
    for assembly in unique_assemblies:
        assembly_length = query_taxid.loc[query_taxid.loc[:, 'assembly_accession'] == assembly].loc[:, 'length'].sum()
        assemblies_lengths.append([assembly, assembly_length])
    assemblies_lengths = pd.DataFrame(assemblies_lengths)
    assemblies_lengths.columns = ['assembly', 'length']
    assemblies_lengths.sort_values('length', ascending=False, inplace=True)
    assemblies_lengths.reset_index(drop=True, inplace=True)
    for i in range(min(assemblies_lengths.shape[0], args.top)):
        query_assembly = query_taxid.loc[query_taxid.loc[:, 'assembly_accession'] == assemblies_lengths.loc[i, 'assembly']]
        query_assembly.to_csv(args.output, mode='a', header=False, index=False, sep='\t')
