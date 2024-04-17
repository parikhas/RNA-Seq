#!/bin/sh
nice -n19 iit_store \
-G /scratch/AiptasiaMiSeq/\
GCA_001417965.1_Aiptasia_genome_1.1_genomic.gff \
-o AiptasiaGmapIIT \
1>buildIIT.log 2>buildIIT.err &
