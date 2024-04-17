#!/bin/sh
fastqPath="/scratch/AiptasiaMiSeq/fastq/"
trimmedPath="Trimmed/"
for f1 in $fastqPath*.R1.fastq
do
	f2=$(echo $f1 | cut -d'.' -f1)
	numOcc=$(tr -dc '/' <<<"$f2" | awk '{ print length; }')
	((numOcc ++))
	f3=$(echo $f2 | cut -d'/' -f$numOcc)
	nice -n 19 gsnap \
	-A sam \
	-s AiptasiaGmapIIT.iit \
	-D . \
	-d AiptasiaGmapDb \
	$trimmedPath$f3.R1.paired.fastq \
	$trimmedPath$f3.R2.paired.fastq \
	1>$f3.sam 2>$f3.err &
done
