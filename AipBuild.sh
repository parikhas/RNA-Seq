#!/bin/sh
gmap_build -D . \
-d AiptasiaGmapDb \
/scratch/AiptasiaMiSeq/\
GCA_001417965.1_Aiptasia_genome_1.1_genomic.fna \
1>AipBuild.log 2>AipBuild.err &
