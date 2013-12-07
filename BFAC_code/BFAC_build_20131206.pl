#!/usr/bin/perl -w

#------------------------------------------
# code adapted from FACS 2009
# Bing He, Stephen Cristiano 2013-12-06
# original author: Stranneheim Henrik
# original auhtor for BLOOM::FASTER: Dmitriy Ryaboy and Peter Alvaro
# Builds Bloom filters with a given K-mer length, false positive rate
# and reference in a FASTA format
# link to FACS: http://facs.scilifelab.se
#------------------------------------------

=head1 SYNOPSIS

BloomBuild reference

Build Bloom filters from reference genomes in fasta files. These
can later be queried using FACS.

-r/--reference A file containing a list of filenames for reference genome data. Each line contains a filename. 
Each file is a Fasta file. (defaults to STDIN)

NOTE: Presently the Bloom::FASTER module has problems
with garbage collection which only enables one reference to built each time the program loads. 
Supplying references in batch might cause a high false positive rate. 

-os/--outfile Output suffix for the created Bloom filter (defaults to .obj)

-k/--kmer Word length for K-mers inserted into the filter (defaults to '21')

-f/--falseposprob The false positive probaility that you accept (defaults to '0.0005')

-dbpr/--databsepath The unixpath to the references (defaults to STDIN)

-dbpo/--databsepath The unixpath to the output directory (defaults to STDIN)

I/O
Input format (FASTA/Pearson)

Output format (Bloom filter)

=head1 SEE ALSO

FACS

=cut

use strict;
use lib '/home/bst/student/bhe2/lib';
use Bloom::Faster;
use Getopt::Long;
use Pod::Usage;

use vars qw($USAGE);

BEGIN {
    $USAGE =
qq{bloombuild.pl < file.fa > file.obj
-k/--kmer Word length for K-mers inserted into the filter (defaults to '21')
-f/--falseposprob The false positive probaility that you accept (defaults to '0.0005')
-r/--reference A file containing a list of filenames for reference genome data. Each line contains 
a filename. Each file is a Fasta file. (defaults to STDIN)

NOTE: Presently the Bloom::FASTER module has problems
with garbage collection which only enables one reference to built each time the program loads. 
Supplying references in batch might cause a high false positive rate.

-os/--outfilesuffix Output suffix for the created Bloom filter (defaults to .obj)
-dbpr/--databsepath The unixpath to the references (defaults to STDIN)
-dbpo/--databsepath The unixpath to the output directory (defaults to STDIN)
};

}
my ($rformat, $oformat, $outfilesuffix, $kmerlength, $falseposratebloom, $dbpr, $dbpo, 
$help) = ('fasta','bloom', ".obj", 21, 0.0005,".", ".");
my ($ref);

GetOptions('k|kmerlength:i' => \$kmerlength,
'f|falseposratebloom:s' => \$falseposratebloom,
'r|reference:s' => \$ref,
'os|outfile:s' => \$outfilesuffix,
'dbpr|databaseref:s'  => \$dbpr,
'dbpo|databaseout:s'  => \$dbpo,
'h|help' => \$help,
);

die $USAGE if( $help );

my $start = time();

#Inputs references to create bloom filters

if ($ref) {

	}
else {

($ref) = @ARGV;

if (@ARGV != 1) {
  my $verbosity = 0;
  if (@ARGV == 0) {
    $verbosity = 2;
  }
  print"\n";
  pod2usage({-message => "Must supply reference.\n",
	     -verbose => $verbosity
	    });
	}
}
#Reads reference list
ReferenceList($ref);

my $id;	
my $seq;
my %seqs;
my $headercount;

my $refid;
my @refs;
my $refcount=0;

my $keycount;
my $filtercounter=0;

for (my $refid=0;$refid<scalar(@refs);$refid++) { 

	print STDERR "BloomFilter Counter:","\t", $refid,"\n";
	print STDERR "Reference Id:","\t", $refs[$refid],"\n";
	print STDERR "K-mer length:","\t", $kmerlength,"\n";
	print STDERR "False Positive Rate Bloom Filter:","\t", $falseposratebloom,"\n"; 

    Refseq($refs[$refid], $refid);
    	

    for $id (keys %seqs) {	

    #Adds keys to the filter
    Targetkeys($seqs{$id}, $refid); 
    
    $id .=$outfilesuffix;
    print "Before $id\n";
    $id =~ /\|(NC_.+?)\|/;
    $id = $1."_".$kmerlength."_".$falseposratebloom.$outfilesuffix;
    print STDOUT "After ".$id."\n";

    #Saves Bloom filter 
    Savebloom($id, $refid);	
    
    #Resets %seqs & undefines bloom filter
    Blank($refid);

    }
}

my $end = time();
print STDOUT "Time:",($end-$start)," second\n";

##########
#End of main program
##########

##########
##Subroutines
# my $id - Capture header in reference file	
# my $seq - Capture sequence in reference file
# my %seqs - Stores header and sequence in reference file  
# my $headercount - Counts the number of headers in reference file
##########
# my $refid - Capture filename in reference list
# my @refs - Stores filename in reference list
# my $refcount - Counts the number of filenames in reference file
##########
# my $keycount - Number of keys in filter
# my $filtercounter - Counts the number of filters created
##########


sub Bloomfilter {
    
	$keycount = $_[0];
	$$_[1] = Bloom::Faster->new({n => $keycount, e => $falseposratebloom});
    
}


sub Savebloom {

    $$_[1]->to_file("$dbpo/$_[0]");
    
}


sub Blank {

    %seqs=();
    undef($$_[1]);
}


sub Targetkeys {
    
      my ($seq) = $_[0]; 
    
	my $lengthseq = length($seq)-($kmerlength-1); #Stops sliding window at the end

	for (my $i=0;$i<$lengthseq;$i++) {	

	$$_[1]->add (substr ($seq, $i, $kmerlength) );
	
    }

    print STDERR "Added Reference Keys to Filter", "\n";
    return;
    
}


sub Refseq {
    
open(FASTA, "<$dbpr/$_[0]") or die "Can't open $_[0]:$!, \n";
    while(<FASTA>) {

	if (/>/) {
	   
	    $seq ="";
	    chomp($id = $'); #'
	    $headercount++;
	}
	
	else {

	    chomp($seq .= $_);
	}
	
    }

    $seqs{$id}= $seq;
    print STDERR "Finished Reading Reference Sequence","\n";
    close(FASTA);
	#Determines bitvector length & creates vector
	Bloomfilter(length($seqs{$id}), $$_[1] );  
    return;
    
}

sub ReferenceList {

open(BLOOM, "<$_[0]") or die "Can't open $_[0]:$!, \n";

    while(<BLOOM>) {
	
	if (/\S+/) {

      chomp;
      $refcount++;
      push @refs, $_;
    }


    }
    
    close(BLOOM);
  if ($refcount == 0) {
    print STDERR "Did not find any files in reference file '$ref'\n";
  }

    print STDERR "Finished Reading Bloom List","\n"; 
    return;
}






