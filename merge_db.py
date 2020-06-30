#!/usr/bin/env python3

# AddDB Updater

# Import library
import pandas as pd
import numpy as np
import sys
import datetime

# Import file from arguments

hgnc_file = sys.argv[1]
omim_file = sys.argv[2]
gnomad_score_file = sys.argv[3]
uniprot_file = sys.argv[4]

# Parser function

## HGNC

def hgnc(file):
    hgnc = pd.read_csv(file, sep='\t')
    hgnc.rename(columns={'Approved symbol': '#Gene_name'}, inplace=True)
    hgnc = hgnc.sort_values(by=['#Gene_name'])
    hgnc = hgnc.reset_index(drop=True)
    return(hgnc)

## GnomAD constraint score

def gnomad_score(file):
    gnomad = pd.read_csv(file, sep='\t',header=0)
    gnomad.rename(columns={'gene': '#Gene_name'}, inplace=True)
    gnomad_select = gnomad[['#Gene_name', 'oe_lof_upper_rank',
       'oe_lof_upper_bin','oe_lof','oe_lof_lower','oe_lof_upper','oe_mis','oe_mis_lower', 'oe_mis_upper','oe_syn','oe_syn_lower', 'oe_syn_upper','constraint_flag']]
    gnomad_select = gnomad_select.sort_values(by=['#Gene_name'])
    gnomad_select = gnomad_select.groupby('#Gene_name', as_index=False).min()
    gnomad_select = gnomad_select.reset_index(drop=True)
    return(gnomad_select)

## OMIM genemap2

def omim(file):
    omim = pd.read_csv(file, sep='\t',skiprows=3)
    omim_select = omim[['Approved Symbol','Phenotypes']]
    omim_select.rename(columns={'Approved Symbol': '#Gene_name'}, inplace=True)
    omim_select = omim_select.dropna(subset=['#Gene_name']) 
    omim_select = omim_select.sort_values(by=['#Gene_name'])
    omim_select = omim_select.fillna('')
    omim_select = omim_select.groupby('#Gene_name', as_index=False)['Phenotypes'].max()
    omim_select = omim_select.drop_duplicates()
    omim_select= omim_select.reset_index(drop=True)
    return(omim_select)

## UniProt database

def explode(df, lst_cols, fill_value='', preserve_index=False):
    # make sure `lst_cols` is list-alike
    if (lst_cols is not None
        and len(lst_cols) > 0
        and not isinstance(lst_cols, (list, tuple, np.ndarray, pd.Series))):
        lst_cols = [lst_cols]
    # all columns except `lst_cols`
    idx_cols = df.columns.difference(lst_cols)
    # calculate lengths of lists
    lens = df[lst_cols[0]].str.len()
    # preserve original index values    
    idx = np.repeat(df.index.values, lens)
    # create "exploded" DF
    res = (pd.DataFrame({
                col:np.repeat(df[col].values, lens)
                for col in idx_cols},
                index=idx)
             .assign(**{col:np.concatenate(df.loc[lens>0, col].values)
                            for col in lst_cols}))
    # append those rows that have empty lists
    if (lens == 0).any():
        # at least one list in cells is empty
        res = (res.append(df.loc[lens==0, idx_cols], sort=False)
                  .fillna(fill_value))
    # revert the original index order
    res = res.sort_index()
    # reset index if requested
    if not preserve_index:        
        res = res.reset_index(drop=True)
    return res

def uniprot(file):
    uniprot = pd.read_csv(file, sep='\t')
    uniprot_select = uniprot.iloc[:,3:]
    uniprot_select.rename(columns={'Gene names  (primary )': 'Gene_name'}, inplace=True)
    uniprot_select = uniprot_select.dropna(subset=['Gene_name']) 
    uniprot_select = explode(uniprot_select.assign(Gene_name=uniprot_select['Gene_name'].str.split(';')),lst_cols=['Gene_name'])
    uniprot_select.rename(columns={'Gene_name': '#Gene_name'}, inplace=True)
    uniprot_select.rename(columns={'Tissue specificity': 'Tissue_specificity(Uniprot)'}, inplace=True)
    uniprot_select.rename(columns={'Function [CC]': 'Function_description'}, inplace=True)
    uniprot_select.rename(columns={'Involvement in disease': 'Disease_description'}, inplace=True)
    uniprot_select = uniprot_select.groupby('#Gene_name', as_index=False).min()
    uniprot_select = uniprot_select.sort_values(by=['#Gene_name'])
    uniprot_select = uniprot_select.drop_duplicates()
    uniprot_select = uniprot_select.reset_index(drop=True)
    return(uniprot_select)

# Merge into one file

def merge_db(hgnc_file,omim_file,gnomad_score_file,uniprot_file):
    hgnc_list = hgnc(hgnc_file)
    omim_list = omim(omim_file)
    gnomad_score_list = gnomad_score(gnomad_score_file)
    uniprot_list = uniprot(uniprot_file)
    gene_fullxref = hgnc_list.merge(omim_list,on='#Gene_name',how='left').merge(gnomad_score_list,on='#Gene_name',how='left').merge(uniprot_list,on='#Gene_name',how='left')
    gene_fullxref = gene_fullxref.sort_values(by=['#Gene_name'])
    gene_fullxref = gene_fullxref.drop_duplicates()
    gene_fullxref = gene_fullxref.fillna('.')
    return gene_fullxref

# Run
today = datetime.date.today()
filename = 'data/gene_fullxref_'
filename += str(today)
filename += '.txt'

gene_fullxref_list = merge_db(hgnc_file,omim_file, gnomad_score_file, uniprot_file)
gene_fullxref_list = gene_fullxref_list.replace('\+','plus',regex=True)
gene_fullxref_list.loc[:,['Approved name','Phenotypes','Function_description','Disease_description','Tissue_specificity(Uniprot)']] = gene_fullxref_list.loc[:,['Approved name','Phenotypes','Function_description','Disease_description','Tissue_specificity(Uniprot)']].replace('-','_',regex=True)
gene_fullxref_list.loc[:,['Phenotypes']] = gene_fullxref_list.loc[:,['Phenotypes']].replace('\(','_',regex=True)
gene_fullxref_list.loc[:,['Phenotypes']] = gene_fullxref_list.loc[:,['Phenotypes']].replace('\)','_',regex=True)
gene_fullxref_list.columns = gene_fullxref_list.columns.str.replace(' ','_')
gene_fullxref_list.to_csv(filename,sep='\t',index=False)

