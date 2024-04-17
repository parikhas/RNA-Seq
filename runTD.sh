#!/bin/bash	

#Find open reading frames in the assembly of gg file using TransDecoder
nice -n19 /usr/local/programs/TransDecoder-5.0.1/\
TransDecoder.LongOrfs -t Trinity-GG.fasta

#Find ORFs most likely to be proteins in gg file using TransDecoder
nice -n19 /usr/local/programs/TransDecoder-5.0.1/\
TransDecoder.Predict -t Trinity-GG.fasta

#Find open reading frames in the assembly of DeNovousing TransDecoder
nice -n19 /usr/local/programs/TransDecoder-5.0.1/\
TransDecoder.LongOrfs -t Trinity.fasta

#Find ORFs most likely to be proteins in DeNovousing TransDecoder
nice -n19 /usr/local/programs/TransDecoder-5.0.1/\
TransDecoder.Predict -t Trinity.fasta

#Substitute an empty string for the asterix for the genome guided assembly file
sed -i 's/\*//g' Trinity-GG.fasta.transdecoder.pep

#Substitute an empty string for the asterix for the deNovo file
sed -i 's/\*//g' Trinity.fasta.transdecoder.pep
