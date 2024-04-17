#!/bin/bash
#Align transcriptome to the swissprot database 
#Specify the fasta file containing the proteins using -query
#Make the output format XML by -outfmt 5
#Use -evalue to give significane cut off of .001 for the blast hits 
#Use 4 threads
#Give the output to Trinity-gg.blastp.xml and specify the files for stdout and stderr
nice -n19 blastp -db /blastDB/swissprot \
-query Trinity-GG.fasta.transdecoder.pep \
-outfmt 5 -evalue .001 -num_threads 4 \
-out Trinity-GG.blastp.xml \
1>blastp.log 2>blastp.err &
