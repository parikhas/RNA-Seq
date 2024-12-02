#!/bin/bash

# Trim the raw reads using Trimmomatic to remove low quality reads and adapters

fastqPath="raw_fastq/"
trimPath="trimmed_fastq/"
for fastq in $fastqPath*.R1.fastq
do
	echo $fastq
	f1=$(echo $fastq | cut -d'.' -f1)
	numOcc=$(tr -dc '/' <<<"$f1" | awk '{ print length; }')
	((numOcc ++))
	f2=$(echo $f1 |cut -d'/' -f$numOcc)
	java -jar /usr/local/programs/Trimmomatic-0.36/trimmomatic-0.36.jar PE \
	-threads 1 -phred33 \
	$fastqPath$f2.R1.fastq \
	$fastqPath$f2.R2.fastq \
	$trimPath$f2.R1.paired.fastq \
	$trimPath$f2.R1.unpaired.fastq \
	$trimPath$f2.R2.paired.fastq \
	$trimPath$f2.R2.unpaired.fastq \
	HEADCROP:0 \
	ILLUMINACLIP:/usr/local/programs/Trimmomatic-0.36/adapters/TruSeq3-PE.fa:2:30:10 \
	LEADING:20 TRAILING:20 SLIDINGWINDOW:4:30 MINLEN:36
done
