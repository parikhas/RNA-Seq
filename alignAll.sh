#!/bin/sh

# Align the fastqs to the Aiptasia GMAP database generating alignment sam files

trimmedPath="Trimmed/"
samPath="Sam/"

for f in $trimmedPath*.R1.fastq
do
	f2=$(echo $f | cut -d'.' -f)
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
	1>$samPath$f3.sam 2>$samPath$f3.err &
done
