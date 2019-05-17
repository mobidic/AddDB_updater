# AddDB updater
Script to update external cross reference database into a single file 

This is a script that can download cross referenced databases, parse them and create a unique fully annotated tsv file to replace gene_xref (i.e. for ANNOVAR). This script could be useful to update these databases and be added to the [Achabilarity](https://github.com/mobidic/Achabilarity) container (custom_database.txt).

## Run 

To make it work, git clone this repository and do 

```bash
sh updater.sh
```

## Databases included

- HGNC Approved Gene Name
- GnomAD constraint score (oe for LoF, missense and synonymous variants with confidence interval)
- UniProt database (gene function, tissue specificity, involvment in disease)
- OMIM (phenotype columns of genemap2)

NB: For OMIM database, you need to ask for access and replace the link for genemap2.txt in the updater.sh

## Documentation

A Jupyter Notebook to explain who this script work is available in this repository [AddDB_updater.ipynb](https://github.com/mobidic/AddDB_updater/blob/master/AddDB_updater.ipynb)

-------------------------------------------------------------------------------

**Montpellier Bioinformatique pour le Diagnostique Clinique (MoBiDiC)**

*CHU de Montpellier*

France

![MoBiDiC](https://raw.githubusercontent.com/mobidic/MPA/master/doc/img/logo-mobidic.png)

[Visit our website](https://neuro-2.iurc.montp.inserm.fr/mobidic/)




 
