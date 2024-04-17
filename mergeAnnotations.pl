#!/bin/perl
use Bio::SearchIO;
use Bio::Search::Result::GenericResult;
use Data::Dumper;
use Bio::SeqIO;

#Open the aipSwissProt.tsv for writing
open( $tsvfile, ">", "aipSwissProt.tsv" ) or die $!;

#Print the headers for the tsv file
print $tsvfile("Trinity","\t","SwissProt","\t","SwissProtDesc","\t","eValue","\n");

#Initiate Bio::SearchIO to $blastXml and direct it to read the xml file
my $blastXml = Bio::SearchIO->new(
	-file   => 'Trinity-GG.blastp.xml',
	-format => 'blastxml'
);

#Keep getting blast results till the end of the xml file
while ( my $result = $blastXml->next_result() ) {
	my $queryDesc = $result->query_description;
	#Put a regex to match any character between colon in query_description 
	if ( $queryDesc =~ /::(.*?)::/ ) {
		#Capture the matched part as $1
		my $queryDescShort = $1;
		#Get the first hit from the blast results for annotation
		my $hit            = $result->next_hit;
		#If there's a hit then...
		if ($hit) {
			#Print the attributes we want
			print $tsvfile ( $queryDescShort,"\t");
			print $tsvfile ( $hit->accession,"\t");
			my $subjectDescription = $hit->description;
			#capture the part between Full= and semicolon or opening paranthesis
			if ( $subjectDescription =~ /Full=(.*?);/ ) {
				$subjectDescription = $1;
			}
			#capture the part between Full= and semicolon or opening paranthesis
			if ( $subjectDescription =~ /Full=(.*?)\[/ ) {
				$subjectDescription = $1;
			}
			#Print the results to the Output file
			print $tsvfile ($subjectDescription,"\t");
			print $tsvfile ($hit->significance,"\n");
		}
	}
}
