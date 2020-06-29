#!/bin/bash

# AddDB Updater

## Check if data folder exists and remove previous file

if [ ! -d data/ ]
then 
	mkdir data
fi 

rm -f data/hgnc.tsv
rm -f data/gnomad.v2.1.1.lof_metrics.by_gene.txt
rm -f data/uniprot.tsv
rm -f data/genemap2.txt
rm -f data/gene_fullxref.txt

## Download databases

### HGNC HUGO gene name (approved symbol and approved name)
wget -O data/hgnc.tsv 'https://www.genenames.org/cgi-bin/download/custom?col=gd_app_sym&col=gd_app_name&status=Approved&hgnc_dbtag=on&order_by=gd_app_sym_sort&format=text&submit=submit'

### gnomAD constraint scores
wget -O data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz 'https://storage.googleapis.com/gnomad-public/release/2.1.1/constraint/gnomad.v2.1.1.lof_metrics.by_gene.txt.bgz' 
gunzip data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz

### UniProt data
wget -O data/uniprot.tsv 'https://www.uniprot.org/uniprot/?query=&fil=organism:9606+AND+reviewed:yes&columns=id,reviewed,protein names,genes(PREFERRED),comment(FUNCTION),comment(TISSUE SPECIFICITY),comment(DISEASE)&format=tab&compress=no'

### OMIM genemap2 according to your personnal Data Account Registration
wget -P data 'https://data.omim.org/downloads/FLmRA_-rRN2mSCUPfnabqg/genemap2.txt'

## Merge data into 
python3 merge_db.py data/hgnc.tsv data/genemap2.txt data/gnomad.v2.1.1.lof_metrics.by_gene.txt data/uniprot.tsv
 
