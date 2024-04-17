#!/usr/bin/perl
use warnings;
use strict;

#Open spToGo.tsv file for reading
open( SP_TO_GO, "<", "spToGo.tsv" ) or die $!;

#Initialise a hash to store the contents of the file
my %spToGo;

#Open the file and split the first two colums separated by tab and assign variables to each of them
while (<SP_TO_GO>) {
	chomp;
	my ( $swissProt, $go ) = split( "\t", $_ );
	#Put both the variables as keys of the hash and increment a counter to store the value
	$spToGo{$swissProt}{$go}++;
}

#Open spToGo.tsv file for reading
open( TSV, "<", "bioProcess.tsv" ) or die $!;

#Initialise a hash to store the contents of the file
my %tsv;

#Loop through the file line-by-line, remove end of line characters and split the first two colums separated by tab and assign variables to each of them
while (<TSV>) {
	chomp;
	my ( $go, $go_desc ) = split( "\t", $_ );
	#Put the first variable as the key and the second variable as the value to that key
	$tsv{$go} = $go_desc;
}

#Open aipSwissProt.tsv file for reading
open( SP, "<", "aipSwissProt.tsv" ) or die $!;

#Open trinitySpGo.tsv file for writing
open (OUT, ">", "trinitySpGo.tsv") or die $!;

while (<SP>) {
	chomp;
	#Open aipSwissProt.tsv and split the four columns by tab and assign variables to them
	my ( $trinity, $swissProt, $description, $eValue ) = split( "\t", $_ );
	#If swissprot id is defined in hash, loop through the keys
	if ( defined $spToGo{$swissProt} ) {
		foreach my $go ( sort keys %{$spToGo{$swissProt}} ) {
			#If $go is defined, then print the variables we want to the output file
			if ( defined $tsv{$go} ) {
				print OUT join( "\t",
					$trinity, $description, $swissProt, $go, $tsv{$go} ),
				  "\n";
			}
		}
	}
}

