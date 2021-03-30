#!/usr/bin/perl -w 

=head1 NAME

.pl

-head1 SYNOPSIS

=head1 OPTIONS

    -inFileT|it <string>
    -inFileH|ih <string>
    -cover|c <float>  # default: 0.05
    -tumorFrac|t <float> # default: 0.05
    -outFile|o <string>
    -purity|p <float>

=head1 DESCRIPTION

=head1 CONTACT

Gavin Ha <gha@bccrc.ca>

=cut

use strict;
#use DBI;
use File::Basename;
use Getopt::Long;

sub usage () {
    exec('perldoc', $0);
    exit;
}

# Declare variables for our input parameters
my ($inFileT, $inFileH, $cover, $tumorFrac, $outFile, $purity);

# Get the options provided and assign them accordingly
GetOptions (
    'inFileT|it=s' => \$inFileT,
    'inFileH|ih=s' => \$inFileH,
    'cover|c=f' => \$cover,
    'tumorFrac|t=f' => \$tumorFrac,
    'outFile|o=s' => \$outFile,
    'purity|p=s' => \$purity,
    );

# Print the provided parameters to the prompt as a check on the input
print "Parameters:\ninFileT=$inFileT\ncover=$cover\noutFile=$outFile\ntumorFrac=$tumorFrac\ninFileH=$inFileH\npurity=$purity\n";

# Get total number of reads for provided coverage and tumor / healthy reads we need
my $targetReads = $cover * 3e7;
my $targetReadsTumor = sprintf("%0.0f", $tumorFrac * $targetReads);
my $targetReadsHealthy = $targetReads - $targetReadsTumor;

# Try getting the number of observed reads in those metrics files
my $numObsReadsT = getNumberPFAlignedReads($inFileT);
my $numObsReadsH = getNumberPFAlignedReads($inFileH);

# Check what the highest coverage possible might be and if the target coverage will work
my $maxCover = ($numObsReadsT + $numObsReadsH) / (3e7);
if ($cover > $maxCover){
	print "Requested coverage is too high, insufficient reads...\n";
} else {
	print "Requested coverage is possible, proceeding...\n";
}

# ----CREATE PROBABILITIES----

# Break up the tumor sample into tumor + healthy reads using the purity fraction
my $tReadsTumor = sprintf("%0.0f", $purity * $numObsReadsT);
my $tReadsHealthy = $numObsReadsT - $tReadsTumor;
my $hReadsHealthy = $numObsReadsH;
my $totalReadsHealthy = $tReadsHealthy + $hReadsHealthy;

# Now find the downsampling probability for the tumor sample
my $tProb = 0;
if ($tReadsTumor > $targetReadsTumor){
	$tProb = $targetReadsTumor / $tReadsTumor;
	print "Probability for tumor file is $tProb ...\n";
} else {
	print "Insufficient tumor reads, cannot create probability...\n";
}

# Now find the downsampling probability for the healthy sample
my $hProb = 0;
if ($hReadsHealthy > ($targetReadsHealthy - sprintf("%0.0f", $tProb * $tReadsHealthy))){
	$hProb = ($targetReadsHealthy - sprintf("%0.0f", $tProb * $tReadsHealthy)) / $hReadsHealthy;
	print "Probability for healthy file is $hProb ...\n";
} else {
	print "Insufficient healthy reads, cannot create probability...\n";
}

# We have the downsample probabilities, now we can write the scripts

# ----WRITE SCRIPTS----

# Create an output file that will hold information about the calculated probabilities
# or provide information on why they couldn't be created
open SCRIPT, ">$outFile" || die("Can't write to $outFile\n");

# If the probabilities were successfully created, write some lines
# Otherwise provide some data on why it didn't work
if ($tProb > 0 && $hProb > 0){

	print SCRIPT "SUFFICIENT HEALTHY/TRUMOR READS...\n";
	print SCRIPT "Target coverage\t$cover\n";
	print SCRIPT "Target tumor fraction\t$tumorFrac\n";
	print SCRIPT "Tumor sample purity\t$purity\n";
	print SCRIPT "Needed healthy reads\t$targetReadsHealthy\n";
	print SCRIPT "Needed tumor reads\t$targetReadsTumor\n";
	print SCRIPT "Healthy reads, normal sample\t$hReadsHealthy\n";
	print SCRIPT "Healthy reads, tumor sample\t$tReadsHealthy\n";
	print SCRIPT "Tumor reads, tumor sample\t$tReadsTumor\n";
	print SCRIPT "Total healthy reads\t$totalReadsHealthy\n";
	print SCRIPT "The values below will be used for downsampling:\n";
	print SCRIPT "----------------------------------\n";
	print SCRIPT "TUMORPROB\t$tProb\n";
	print SCRIPT "HEALTHYPROB\t$hProb\n";

} else {

	print SCRIPT "ERROR: INSUFFICIENT HEALTHY/TUMOR READS...\n";
	print SCRIPT "Target coverage\t$cover\n";
	print SCRIPT "Target tumor fraction\t$tumorFrac\n";
	print SCRIPT "Tumor sample purity\t$purity\n";
	print SCRIPT "Needed healthy reads\t$targetReadsHealthy\n";
	print SCRIPT "Needed tumor reads\t$targetReadsTumor\n";
	print SCRIPT "Healthy reads, normal sample\t$hReadsHealthy\n";
	print SCRIPT "Healthy reads, tumor sample\t$tReadsHealthy\n";
	print SCRIPT "Tumor reads, tumor sample\t$tReadsTumor\n";
	print SCRIPT "Total healthy reads\t$totalReadsHealthy\n";
	print SCRIPT "Max coverage possible\t$maxCover\n";
	print SCRIPT "Coverage and read status below:\n";
	print SCRIPT "-----------------------------------\n";

	# Check requested coverage
	if ($cover < $maxCover) {
		print SCRIPT "Requested coverage is possible\n";
	} else {
		print SCRIPT "Not enough reads for the requested coverage\n";
	}

	# Check the number of tumor reads
	if ($targetReadsTumor > $tReadsTumor){
		print SCRIPT "Insufficient observed tumor reads\n";
	} else {
		print SCRIPT "Sufficient observed tumor reads\n";
	}

	# Check the number of healthy reads
	if ($targetReadsHealthy > $totalReadsHealthy){
		print SCRIPT "Insufficient observed healthy reads\n";
	} else {
		print SCRIPT "Sufficient observed healthy reads\n";
	}

}

# Close the file we were writing to
close SCRIPT;

# ----FUNCTIONS----

# Function to get the number of PF aligned reads from a metrics file
sub getNumberPFAlignedReads{

	# Load metrics file to see current number of reads aligned
	my $metricsFile = $_[0];
	my $numObsReads = 0;
	if ( -e $metricsFile){
		open METRIC, $metricsFile || die "Can't open $metricsFile\n";
		while(<METRIC>){
			chomp;	
			
			# Find the line starting with the word PAIR
			if (substr($_, 0, 4) eq "PAIR"){
				my (@metrics) = split(/\t/, $_);
				$numObsReads = $metrics[5];
			}else{
				# print "Can't find line for coverage.\n";
			}
		}
		close METRIC;
	}else{
		print "Can't find file $metricsFile\n";
	}
	return($numObsReads);
}
