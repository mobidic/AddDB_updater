#!/usr/local/bin/perl
use strict;
use warnings;

use HTTP::Tiny;
use JSON;
use Encode;
use Data::Dumper;

use Getopt::Long;


#parameters
my $man = "USAGE : search_hgnc.pl
\n--file <gene symbol file> (mandatory)
\n--symbolColumn <number of column that contains gene symbol>
\n\n-v|--version < return version number and exit > ";


my $version = "search_hgnc version 1.0.0";
my $file = "";
my @file_List = "";
my $file_line = "";
my $symbolCol = "1";



my $http = HTTP::Tiny->new();

my $response = "";
my $server = 'https://rest.genenames.org';
my $request_type = '/search/';
my $query = '';
my $result = "";



GetOptions(     "file=s"                         => \$file,
			    "symbolColumn"   => \$symbolCol,
			    "version|v"   => \$version);



my $output = $file."_HGNC_Checked.txt";

#file treatment
if($file ne ""){

	
	open(INPUT , "<$file") or die("Cannot open file ".$file) ;
	
	open(OUTPUT , '>' , $output) or die $!;

	print  STDERR "Processing input file ... \n" ;
	while( <INPUT> ){
		$file_line = $_;
		#############################################
		##############   skip header
		
		chomp $file_line;
		@file_List = split( /\t/, $file_line );
		
		if ($file_line=~/^#/){
			push(@file_List,"hgnc_id");
			print OUTPUT join("\t",@file_List)."\n";
			next;
		}
		if ($file_line=~/^gene/){
			push(@file_List,"hgnc_id");
			print OUTPUT join("\t",@file_List)."\n";
			next;
		}
		
		#replace "spaces" by "_"
		#$file_List[7] =~ s/ /_/g;
		
		#build variant key as CHROM_POS_REF_ALT
		
		$query=$file_List[0];
		print $query."\n";

		$response = $http->get($server.$request_type.$query, {headers => { 'Accept' => 'application/json' }	});

		die "Failed!\n" if $response->{status} ne '200';
		my $json_bytes = encode('UTF-8', $response->{content});
		my $result = decode_json($json_bytes);
		
		if ($result->{response}->{numFound} < 1){
			push(@file_List,"");
			print OUTPUT join("\t",@file_List)."\n";
		}else{
			@file_List[0]=$result->{response}->{docs}[0]{symbol};
			push(@file_List,$result->{response}->{docs}[0]{hgnc_id});
			$file_List[-1] =~ s/HGNC://;
			print OUTPUT join("\t",@file_List)."\n";
		}

	}
		
	close(INPUT);
}
		
close(OUTPUT);





#my $statement = q{There are %d genes that contain the phrase } .
#q{"MAP kinase interacting" } .
#q{within the approved name which have the locus type} .
#q{"gene with protein product"};

#printf $statement, $result->{response}->{numFound};
#printf $result->{response}->{numFound};
#printf $result->{response}->{docs}[0]{hgnc_id};
#print Dumper($result);
exit 0;
