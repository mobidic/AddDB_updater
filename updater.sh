#!/bin/bash

# AddDB Updater

## Download databases

### HGNC HUGO gene name (approved symbol and approved name)
wget -P data 'https://www.genenames.org/cgi-bin/download/custom?col=gd_app_sym&col=gd_app_name&status=Approved&hgnc_dbtag=on&order_by=gd_app_sym_sort&format=text&submit=submit'
mv data/'custom?col=gd_app_sym&col=gd_app_name&status=Approved&hgnc_dbtag=on&order_by=gd_app_sym_sort&format=text&submit=submit' data/hgnc.tsv

### gnomAD constraint scores
wget -P data 'https://storage.googleapis.com/gnomad-public/release/2.1.1/constraint/gnomad.v2.1.1.lof_metrics.by_gene.txt.bgz' 
mv data/gnomad.v2.1.1.lof_metrics.by_gene.txt.bgz data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz
gunzip data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz

### UniProt data

wget -P data 'https://www.uniprot.org/uniprot/?query=&fil=organism:9606+AND+reviewed:yes&columns=id,reviewed,protein names,genes(PREFERRED),comment(FUNCTION),comment(TISSUE SPECIFICITY),comment(DISEASE)&format=tab&compress=no'
mv data/'index.html?query=&fil=organism:9606+AND+reviewed:yes&columns=id,reviewed,protein names,genes(PREFERRED),comment(FUNCTION),comment(TISSUE SPECIFICITY),comment(DISEASE)&format=tab&compress=no' data/uniprot.tsv

### OMIM genemap2

wget -P data 'https://data.omim.org/downloads/FLmRA_-rRN2mSCUPfnabqg/genemap2.txt'

## Merge data into 

python3 merge_db.py data/hgnc.tsv data/genemap2.txt data/gnomad.v2.1.1.lof_metrics.by_gene.txt data/uniprot.tsv
 
