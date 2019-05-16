source ucsc_download.sh
get_whole_genome_table summary.tsv.gz genes refGene hgFixed.refSeqSummary gzip

VIA le table browser de ucsc cf CAPTURES ecran dans ce dossier:
Selection et related tables de 
"group: All Tables" +  "database:hgFixed" + "table=hgFixed.refSeqSummary"  => selected fields from primary and related tables
Linked Tables: hg19-RefFlat (pour avoir les gene Symbol) => allow selection from checked tables
cocher geneName dans hg19.refFlat fields => get output


puis filtration des doublons et vides comme ceci:


# awk -F "\t" '$4!="n/a" && $3!=""{print}' summaryRefSeq.txt > summaryRefSeq_noNA_noEmpty.txt 
# cut -f3,4 summaryRefSeq_noNA_noEmpty.txt |sort |uniq > summaryRefSeq_noNA_noEmpty_uniq.txt
# awk -F "\t" '{print $2"\t"$1}' summaryRefSeq_noNA_noEmpty_uniq.txt |sort > summaryRefSeq_noNA_noEmpty_uniq_sort.txt

en 1 ligne; awk -F "\t" '$4!="n/a" && $3!=""{print}' summaryRefSeq.txt | cut -f3,4  |sort |uniq | awk -F "\t" '{print $2"\t"$1}' > summaryRefSeq_noNA_noEmpty_uniq_sort.txt

Puis il faut encore eliminer les doublons en supprimant toutes les notes de fins de summary exemple:

%s/##Evidence-Data-START##.*##Evidence-Data-END##//
%s/  Publication Not.*$// 
%s/  Sequence Not.*$//
%s/  This variant (.*$//
%s/  CCDS Note.*$//

%s/##RefSeq-Attributes-START##.*##RefSeq-Attributes-END##// 


et les fins de lignes

Je l'ai fait dans VIM la main: essayer d'automatiser pour la prochaine fois

quelques genes ont une virgule derriÃre eux et quelques lignes sont doublonnÃes pour des questions de variants.
%s/,\t/\t/


sort summaryRefSeq_noNA_noEmpty_uniq_sort_clean_uniq.txt |uniq > summaryRefSeq_noNA_noEmpty_uniq_sort_clean_uniq2.txt
