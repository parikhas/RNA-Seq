#!/bin/sh
nice -n19 /usr/local/programs/\
trinityrnaseq-2.2.0/\
Trinity --genome_guided_bam AipAll.bam \
--genome_guided_max_intron 10000 \
--max_memory 50G --CPU 4 \
1>trinity.log 2>trinity.err &

