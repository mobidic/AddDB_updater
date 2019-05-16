# AddDB_updater
Script to update external cross reference database into a single file 


## Required Input Databases:
Gene_name
#Gene_name	
pLi	pRec	pNull z-score missense LOEUF gnomad https://storage.googleapis.com/gnomad-public/release/2.1.1/constraint/gnomad.v2.1.1.lof_metrics.by_gene.txt.bgz   
Gene_full_name	<= cf uniprot
Function_description <= refseq summary UCSC	<= cf uniprot
Disease_description	<= cf uniprot
Tissue_specificity(Uniprot)	<= cf uniprot
Expression(egenetics)	<= not found
Expression(GNF/Atlas)	<= not found
Phenotypes	<= genemap2
HPO <= clinsyn.Json  + others genes ?


## Sources:
uniprot query
https://www.uniprot.org/uniprot/?query=&fil=organism%3A%22Homo%20sapiens%20(Human)%20%5B9606%5D%22%20AND%20reviewed%3Ayes&columns=id%2Creviewed%2Cprotein%20names%2Cgenes%2Ccomment(FUNCTION)%2Ccomment(TISSUE%20SPECIFICITY)%2Ccomment(INVOLVEMENT%20IN%20DISEASE)

VIA https://www.uniprot.org/database/?query=*&fil=&columns=id
ExpressionAtlas
GeneReviews
GeneCards
GenAtlas
MIM
Orphanet
GeneVisible



uniprot column names for API:
https://www.uniprot.org/help/uniprotkb_column_names


uniprot customize columns:

https://www.uniprot.org/uniprot/?query=*&fil=reviewed%3Ayes+AND+organism%3A%22Homo+sapiens+%28Human%29+%5B9606%5D%22#customize-columns
