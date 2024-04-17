#!/bin/bash
#Get the list of the left reads and store as $leftReads
leftReads="$(ls -q Paired/*.R1.fastq)"
#Store echo of $leftReads as $leftReads to get rid of line breaks
leftReads=$(echo $leftReads)
#Replace spaces in list of reads with comma
leftReads="${leftReads// /,}"
#Get the list of right reads and store as $rightReads
rightReads="$(ls -q Paired/*.R2.fastq)"
#Store echo of $rightReads as $rightReads to get rid of line breaks
rightReads=$(echo $rightReads)
#Replace spaces in list of reads with comma
rightReads="${rightReads// /,}"
nice -n19 /usr/local/programs/\
trinityrnaseq-2.2.0/\
Trinity --seqType fq --max_memory 50G --output trinity_de-novo \
--left $leftReads --right $rightReads --CPU 4 \
1>trinity.log 2>trinity.err &


