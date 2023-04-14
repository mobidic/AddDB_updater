#!/bin/bash

if [ "$#" -lt 1 ]; then
 echo "Missing argument: you should give your personal URL to download OMIM genemap2 file, provided from https://www.omim.org/downloads/  \n"
 echo "usage: sh updater.sh  https://data.omim.org/downloads/my-Registration-Code/genemap2.txt  [OPTIONAL]/path/to/genome/hg19_nochr.fasta   [OPTIOAL]/path/to/genome/hg38_nochr.fasta \n"
 exit 1
fi



# AddDB Updater

#############################################
#update gene_customfullxref for anovar
echo #update gene_customfullxref for anovar
#############################################

## Check if data folder exists and remove previous file

if [ ! -d data/ ]
then 
	mkdir data
fi 

rm -f data/hgnc.tsv*
rm -f data/gnomad.v2.1.1.lof_metrics.by_gene.txt
rm -f data/uniprot.tsv*
rm -f data/genemap2.txt*
rm -f data/gene_fullxref.txt*


## Download databases

### HGNC HUGO gene name (approved symbol and approved name)
wget -O data/hgnc.tsv 'https://www.genenames.org/cgi-bin/download/custom?col=gd_app_sym&col=gd_app_name&status=Approved&hgnc_dbtag=on&order_by=gd_app_sym_sort&format=text&submit=submit'

### gnomAD constraint scores
if [ ! -f data/gnomad.v2.1.1.lof_metrics.by_gene.txt_HGNC_Checked.txt ]
then
	wget -O data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz 'https://storage.googleapis.com/gcp-public-data--gnomad/release/2.1.1/constraint/gnomad.v2.1.1.lof_metrics.by_gene.txt.bgz'
	gunzip data/gnomad.v2.1.1.lof_metrics.by_gene.txt.gz
	#HGNC check/update gene symbols (it take ~ 3 hours)
	#perl ./update_HGNC_symbols.pl --file data/gnomad.v2.1.1.lof_metrics.by_gene.txt
fi

### UniProt data
python uniprot.py
#wget -O data/uniprot.tsv 'https://www.uniprot.org/uniprot/?query=&fil=organism:9606+AND+reviewed:yes&columns=id,reviewed,protein names,genes(PREFERRED),comment(FUNCTION),comment(TISSUE SPECIFICITY),comment(DISEASE)&format=tab&compress=no'

### URL to get OMIM genemap2 according to your personnal Data Account Registration
wget -P data $1 


if [ ! -f data/gnomad.v2.1.1.lof_metrics.by_gene.txt_HGNC_Checked.txt ]
then
	echo "The gnomad file doesn't exists  data/gnomad.v2.1.1.lof_metrics.by_gene.txt_HGNC_Checked.txt, it may takes hours to generate!" 
	exit 1
fi

## Merge data into 
python3 merge_db.py data/hgnc.tsv data/genemap2.txt data/gnomad.v2.1.1.lof_metrics.by_gene.txt_HGNC_Checked.txt data/uniprot.tsv

# check gene_full xref content evolution
awk -F "\t" 'BEGIN{OMIM=0;field1=0;lines=0;fields=0;emptyFields=0;fieldDiff=""}{if($3 !="." && $3 !=""){OMIM++};if (field1==0){field1=NF;fieldDiff=field1} else if(field1!=NF){fieldDiff=fieldDiff";"NF}; lines++;fields+=NF;for(i=1; i<=NF; i++){if($i == "."){emptyFields ++} }}END{print FILENAME"\nLines= "lines"\nField par ligne= "fieldDiff"\nFields totaux= "fields"\nFields vides= "emptyFields"\nRatio fields totaux sur vides= "fields/emptyFields"\nNb OMIM phenotypes= "OMIM} ' data/gene_fullxref_*.txt > data/CHECKING_gene_fullxref.txt

#test ARG 2 : path to hg19 fasta
if [ -n "$2" ]; then


#############################################
#update clinvar for anovar
echo #update clinvar for anovar
#############################################

################ hg19 flavour ###############
echo ########### hg19 flavour ###############

#get last clinvar vcf
wget -O data/hg19_clinvar.vcf.gz  ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh37/clinvar.vcf.gz

#extract file date 
clindate=`zgrep -m 1 -P "##fileDate=2"  data/hg19_clinvar.vcf.gz | sed -e 's/##fileDate=//' -e 's/-//g'`

#step1 split
bcftools norm -m-both -o data/temp_hg19_clinvar_${clindate}_split.vcf data/hg19_clinvar.vcf.gz
 
#preprocess splitted vcf
./prepare_annovar_user.pl -dbtype clinvar_preprocess2   data/temp_hg19_clinvar_${clindate}_split.vcf  -out data/temp_hg19_clinvar_${clindate}_preproc.vcf

#step2 left align preprocessed vcf
bcftools norm -f $2 -o data/temp_hg19_clinvar_${clindate}_leftAlign.vcf  data/temp_hg19_clinvar_${clindate}_preproc.vcf
 
 
#convert to annovar format
./prepare_annovar_user.pl -dbtype clinvar2  data/temp_hg19_clinvar_${clindate}_leftAlign.vcf  -out data/hg19_clinvar_${clindate}.txt

# index file by 1000 bin
./index_annovar.pl   data/hg19_clinvar_${clindate}.txt  1000

# Add header
sed -i '1i #Chr\tStart\tEnd\tRef\tAlt\tCLNALLELEID\tCLNDN\tCLNDISDB\tCLNREVSTAT\tCLNSIG' data/hg19_clinvar_${clindate}.txt



# check clinvar content evolution
awk -F "\t" 'BEGIN{OMIM=0;field1=0;lines=0;fields=0;emptyFields=0;fieldDiff=""}{if($3 !="." && $3!=""){OMIM++};if (field1==0){field1=NF;fieldDiff=field1} else if(field1!=NF){fieldDiff=fieldDiff";"NF}; lines++;fields+=NF;for(i=1; i<=NF; i++){if($i == "." || $i ==""){emptyFields ++} }}END{print FILENAME"\nLines= "lines"\nField par ligne= "fieldDiff"\nFields totaux= "fields"\nFields vides= "emptyFields"\nRatio fields totaux sur vides= "fields/emptyFields"\nNb OMIM phenotypes= "OMIM} ' data/hg19_clinvar_${clindate}.txt > data/CHECKING_hg19_clinvar_${clindate}.txt

# count pathogenicity status in clinvar
cut -f10 data/hg19_clinvar_${clindate}.txt | sort | uniq -c | sort -k1nr >> data/CHECKING_hg19_clinvar_${clindate}.txt





fi


#test ARG 3 : path to hg38 fasta

if [ -n "$3" ]; then

############################################# 
################ hg38 flavour ###############
echo ########### hg38 flavour ###############

#get last clinvar vcf
wget -O data/hg38_clinvar.vcf.gz  ftp://ftp.ncbi.nlm.nih.gov/pub/clinvar/vcf_GRCh38/clinvar.vcf.gz

#get index script
#git clone https://github.com/tsy19900929/cosmic2annovar.git

#extract file date 
clindate=`zgrep -m 1 -P "##fileDate=2"  data/hg38_clinvar.vcf.gz | sed -e 's/##fileDate=//' -e 's/-//g'`

#step1 split
bcftools norm -m-both -o data/temp_hg38_clinvar_${clindate}_split.vcf data/hg38_clinvar.vcf.gz
 
#preprocess splitted vcf
./prepare_annovar_user.pl -dbtype clinvar_preprocess2   data/temp_hg38_clinvar_${clindate}_split.vcf  -out data/temp_hg38_clinvar_${clindate}_preproc.vcf

#step2 left align preprocessed vcf
bcftools norm -f $3 -o data/temp_hg38_clinvar_${clindate}_leftAlign.vcf  data/temp_hg38_clinvar_${clindate}_preproc.vcf
 
 
#convert to annovar format
./prepare_annovar_user.pl -dbtype clinvar2  data/temp_hg38_clinvar_${clindate}_leftAlign.vcf  -out data/hg38_clinvar_${clindate}.txt
 
# index file by 1000 bin
./index_annovar.pl   data/hg38_clinvar_${clindate}.txt  1000

# Add header
sed -i '1i #Chr\tStart\tEnd\tRef\tAlt\tCLNALLELEID\tCLNDN\tCLNDISDB\tCLNREVSTAT\tCLNSIG' data/hg38_clinvar_${clindate}.txt


# check clinvar content evolution
awk -F "\t" 'BEGIN{OMIM=0;field1=0;lines=0;fields=0;emptyFields=0;fieldDiff=""}{if($3 !="." && $3!=""){OMIM++};if (field1==0){field1=NF;fieldDiff=field1} else if(field1!=NF){fieldDiff=fieldDiff";"NF}; lines++;fields+=NF;for(i=1; i<=NF; i++){if($i == "." || $i ==""){emptyFields ++} }}END{print FILENAME"\nLines= "lines"\nField par ligne= "fieldDiff"\nFields totaux= "fields"\nFields vides= "emptyFields"\nRatio fields totaux sur vides= "fields/emptyFields"\nNb OMIM phenotypes= "OMIM} ' data/hg38_clinvar_${clindate}.txt > data/CHECKING_hg38_clinvar_${clindate}.txt

# count pathogenicity status in clinvar
cut -f10 data/hg38_clinvar_${clindate}.txt | sort | uniq -c | sort -k1nr >> data/CHECKING_hg38_clinvar_${clindate}.txt

fi


# compress temp files
echo "~~~ compress temp files ~~~"
rm data/temp*
gzip data/gnomad.v2.1.1.lof_metrics.by_gene.txt
gzip data/uniprot.tsv
gzip data/genemap2.txt
gzip data/hgnc.tsv


exit 0




