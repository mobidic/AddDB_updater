# AddDB updater

This is a script that can download cross referenced databases, parse them and create a unique fully annotated tsv file to replace gene_xref (i.e. for ANNOVAR). Latest Clinvar database can be download and convert into annovar format as well. This script could be useful to update these databases and be added to the [Achabilarity](https://github.com/mobidic/Achabilarity) container (custom_database.txt).

## Run 

To make it work, git clone this repository and do 

```bash
sh updater.sh   https://data.omim.org/downloads/my-Registration-Code/genemap2.txt   [OPTIONAL]/path/to/genome/hg19_nochr.fasta    [OPTIONAL]/path/to/genome/hg38_nochr.fasta 
```

## Requirements

- python (3.6 tested)
- pandas library


## Databases included

- HGNC Approved Gene Name
- GnomAD constraint score (oe for LoF, missense and synonymous variants with confidence interval)
- UniProt database (gene function, tissue specificity, involvment in disease)
- OMIM (phenotype columns of genemap2)
- latest clinvar vcf (hg19 - hg38)

NB: For OMIM database, you need to ask for access (https://www.omim.org/downloads) and give the link for genemap2.txt as argument for the updater.sh

## Documentation

A Jupyter Notebook to explain how this script work is available in this repository [AddDB_updater.ipynb](https://github.com/mobidic/AddDB_updater/blob/master/AddDB_updater.ipynb)

-------------------------------------------------------------------------------

**Montpellier Bioinformatique pour le Diagnostic Clinique (MoBiDiC)**

*CHU de Montpellier*

France

![MoBiDiC](https://raw.githubusercontent.com/mobidic/MPA/master/doc/img/logo-mobidic.png)

[Visit our website](https://neuro-2.iurc.montp.inserm.fr/mobidic/)




 
