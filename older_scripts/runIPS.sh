#!/bin/bash

#Run the interproscanner using Pfam analysis on 8 threads and disable precalculated lookups
#specify output format as XML
#include go terms in the output
#Use pa flag to include kegg output
#Write output to AipIPS.xml
#Put stdout to ips.log and stderr to ips.err and run it in the background
nice -n19 /usr/local/programs/interproscan-5.26-65.0/\
interproscan.sh -appl Pfam -cpu 8 -dp -f XML \
-goterms -i Trinity-GG.fasta.transdecoder.pep \
-iprlookup -pa -o AipIPS.xml \
1>ips.log 2>ips.err &
