#!/bin/sh

# Index the sorted bam files

samPath="Sam/"
for f1 in $samPath*.sam
do
	f2=$(echo $f1 | cut -d'.' -f1)
	numOcc=$(tr -dc '/' <<<"$f2" | awk '{ print length; }')
	((numOcc ++))
	f3=$(echo $f2 | cut -d'/' -f$numOcc)
	samtools index $f3.sorted.bam
done
