#! /bin/bash

#------------------------
mkdir 01.bed && cd 01.bed
sed -e 's/Chr/Ph/g' -e 's/.v2.1//g' ~/genome/PhalliiHAL_v2.1/annotation/PhalliiHAL_496_v2.1.gene_exons.gff3 >PhalliiHAL_496_v2.1.gff3
perl ../00.bin/gff2mcscanXbed-pha.pl PhalliiHAL_496_v2.1.gff3 pha.extract.bed
perl ../00.bin/gff2mcscanXbed-pmi.pl ~/data/pmi.genome/Pmiliaceum.Chr.gff pmi.extract.bed
cat pha.extract.bed pmi.extract.bed >pha_pmi.mcscan.bed
cd ..

#-----------------------
mkdir 02.pep && cd 02.pep
perl ../00.bin/getLongestPep-Pmi.pl ~/data/pmi.genome/Pmiliaceum.Chr.pep.fa >Pmiliaceum.Chr.pep.longest.fa
perl ../rename_pep.pl ~/genome/PhalliiHAL_v2.1/annotation/PhalliiHAL_496_v2.1.protein_primaryTranscriptOnly.fa |sed 's/.p//g' > PhalliiHAL_496_v2.1.ppe.longest.fa
cat PhalliiHAL_496_v2.1.ppe.longest.fa Pmiliaceum.Chr.pep.longest.fa >pha_pmi.mcscan.fa
makeblastdb -in pha_pmi.mcscan.fa -dbtype prot -parse_seqids
blastp -query pha_pmi.mcscan.fa -db pha_pmi.mcscan.fa -out pha_pmi.mcscan.fa.blastout -evalue 1e-10 -outfmt 6 -max_target_seqs 5 -num_threads 16
cd ..

#-----------------------
mkdir 03.MCScanX && cd 03.MCScanX
ln -s ../01.bed/pha_pmi.mcscan.gff pha_pmi.bed
ln -s ../02.pep/pha_pmi.mcscan.fa.blastout pha_pmi.blast
MCScanX ./pha_pmi


#-----------------------
mkdir 04.dotPlotter && cd 04.dotPlotter
echo 1000 >>plot.ctl && echo 1000 >>plot.ctl && echo Pm1a,Pm2a,Pm3a,Pm4a,Pm5a,Pm6a,Pm7a,Pm8a,Pm9a,Pm1b,Pm2b,Pm3b,Pm4b,Pm5b,Pm6b,Pm7b,Pm8b,Pm9b >>plot.ctl && echo Ph01,Ph02,Ph03,Ph04,Ph05,Ph06,Ph07,Ph08,Ph09 >>plot.ctl
java dot_plotter -g ../03.MCScanX/pha_pmi.bed  -s ../03.MCScanX/pha_pmi.collinearity -c plot.ctl -o dot_plotter.png 


