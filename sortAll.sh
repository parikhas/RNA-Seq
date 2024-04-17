#!/bin/bash
fastqPath="/scratch/AiptasiaMiSeq/fastq/"

for f1 in $fastqPath*.R1.fastq
do
	f2=$(echo $f1 | cut -d'.' -f1)
	numOcc=$(tr -dc '/' <<<"$f2" | awk '{ print length; }')
	((numOcc ++))
	f3=$(echo $f2 |cut -d'/' -f$numOcc)
	samtools sort \
	$f3.sam \
	-o $f3.sorted.bam \
	1>$f3.sort.log 2>$f3.sort.err &
done
