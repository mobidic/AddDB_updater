#!/usr/bin/env python3

# AddDB Updater

# Import library
import pandas as pd
import sys

# Import file from arguments

hgnc_file = sys.argv[1]
omim_file = sys.argv[2]
gnomad_score_file= = sys.argv[3]
uniprot_file = sys.argv[4]

# Parser function

## HGNC

def hgnc(file):
    hgnc = pd.read_csv(file, sep='\t')
    hgnc.rename(columns={'Approved symbol': '#Gene_name'}, inplace=True)
    return(hgnc)

## GnomAD constraint score

def gnomad_score(file):
    gnomad = pd.read_csv(file, sep='\t')
    gnomad.rename(columns={'gene': '#Gene_name'}, inplace=True)
    gnomad_select = gnomad[['#Gene_name', 'oe_lof_upper_rank','oe_lof_upper_bin','oe_lof','oe_lof_lower','oe_lof_upper','oe_mis','oe_mis_lower', 'oe_mis_upper','oe_syn','oe_syn_lower', 'oe_syn_upper','constraint_flag']]
    return(gnomad_select)

## OMIM genemap2

def omim(file):
    omim = pd.read_csv(file, sep='\t',skiprows=3)
    omim_select = omim[['Approved Symbol','Phenotypes']]
    omim_select.rename(columns={'Approved Symbol': '#Gene_name'}, inplace=True)
    omim_select = omim_select.dropna(subset=['#Gene_name'])
    return(omim_select)

## UniProt database

def uniprot(file):
    uniprot = pd.read_csv(file, sep='\t')
    uniprot_select = uniprot.iloc[:,3:]
    uniprot_select.rename(columns={'Gene names  (primary )': '#Gene_name'}, inplace=True)
    return(uniprot_select)


# Merge into one file

def merge_db(hgnc_file,omim_file,gnomad_score_file,uniprot_file):
    hgnc_list = hgnc(hgnc_file)
    omim_list = omim(omim_file).reset_index(drop=True)
    gnomad_score_list = gnomad_score(gnomad_score_file)
    uniprot_list = uniprot(uniprot_file)
    gene_fullxref = hgnc_list.merge(omim_list,on='#Gene_name').merge(gnomad_score_list,on='#Gene_name').merge(uniprot_list,on='#Gene_name')
    gene_fullxref = gene_fullxref.fillna('')
    return gene_fullxref

# Run

gene_fullxref_list = merge_db(hgnc_file,omim_file, gnomad_score_file, uniprot_file)
gene_fullxref_list.to_csv('data/gene_fullxref.txt',sep='\t',index=False)

