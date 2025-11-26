#!/usr/bin/perl
use Getopt::Long;

GetOptions (\%opt,"strand:s","genegff:s","tegff:s","fasta:s","refhead:s","help");
#(yliu) "strand:s"

my $help=<<USAGE;
Notice!: (yliu) A simplified version!!!
Can get subfregment of gene gff and te gff for one gene or two genes.
perl $0 --strand --genegff --tegff --fasta --refhead
USAGE

if ($opt{help} or keys %opt < 1) {
	print "$help\n";
	exit();
}

my $refhead = $opt{refhead};
print "Refhead:$refhead\n";
& getsubfasta($opt{fasta}, $refhead, $opt{strand});  #(yliu) "+" or "other"
& getsubgff3($opt{genegff}, $refhead, $opt{strand}) if $opt{genegff};;
& getsubrepeat($opt{tegff}, $refhead, $opt{strand}) if $opt{tegff};

#(yliu) bug would happen when flangking is too long

####################
sub getsubrepeat
{
my ($gff, $head, $strand) = @_;
my @temp = split("_", $head);
my $chr = $temp[1];
my $start = $temp[2];
my $end = $temp[3];
my $len = $end - $start + 1;
if ($strand eq "+") {
	open IN1, "$gff" or die "$!";
	open OUT1, ">>$head.te.gff" or die "$!";
	while (<IN1>) {
		chomp;
		my @unit = split("\t", $_);
		if ($unit[0] eq $chr and $unit[3] >= $start and $unit[4] <= $end) {
			$unit[3] = $unit[3] - $start + 1;  #(yliu) "+1"
			$unit[4] = $unit[4] - $start + 1;  #(yliu) "+1"
			my $line = join("\t", @unit);
			print OUT1 "$line\n";
		}
	}
	close OUT1;
	close IN1;
} else {
	open IN1, "$gff" or die "$!";
	open OUT1, ">>$head.te.gff" or die "$!";
	while (<IN1>) {
		chomp;
		my @unit = split("\t",$_);
		if ($unit[0] eq $chr and $unit[3] >= $start and $unit[4] <= $end) {
			my $tempend = $len - ($unit[3] - $start) + 1;  #(yliu) "+1"
			my $tempstart = $len - ($unit[4] - $start) + 1;  #(yliu) "+1"
			$unit[3] = $tempstart;
			$unit[4] = $tempend;
			if ($unit[6] eq "+"){
				$unit[6] = "-";
			} else {
				$unit[6] = "+";
			}
			my $line = join("\t", @unit);
			print OUT1 "$line\n";
		}
	}
   close OUT1;
   close IN1;
}
}

####################
sub getsubgff3
{
my ($gff, $head, $strand) = @_;
my @temp = split("_", $head);
my $chr = $temp[1];
my $start = $temp[2];
my $end = $temp[3];
my $len = $end - $start + 1;
print "$gff\t$chr\t$start\t$end\n";
if ($strand eq "+") {
	open IN1, "$gff" or die "$!";
	open OUT1, ">>$head.gene.gff" or die "$!";
	while (<IN1>) {
		my @unit = split("\t",$_);
		if ($unit[0] eq $chr and $unit[3] >= $start and $unit[4] <= $end) { 
			$unit[3] = $unit[3] - $start + 1;  #(yliu) "+1"
			$unit[4] = $unit[4] - $start + 1;  #(yliu) "+1"
			my $line = join("\t", @unit);
			print OUT1 "$line";
		}
	}
	close OUT1;
	close IN1;
} else {
	open IN1, "$gff" or die "$!";
	open OUT1, ">>$head.gene.gff" or die "$!";
	while (<IN1>){
		my @unit=split("\t",$_);
		if ($unit[0] eq $chr and $unit[3] >= $start and $unit[4] <= $end) { 
			my $tempend = $len - ($unit[3] - $start) + 1;  #(yliu) "+1"
			my $tempstart = $len - ($unit[4] - $start) + 1;  #(yliu) "+1"
			$unit[3] = $tempstart;
			$unit[4] = $tempend;
			if ($unit[6] eq "+"){
				$unit[6] = "-";
			} else {
				$unit[6] = "+";
			}
			my $line = join("\t", @unit);
			print OUT1 "$line";
		}
	}
   close OUT1;
   close IN1;
}
}

####################
sub getsubfasta
{
my ($fasta, $head, $strand) = @_;
my @temp = split("_", $head);
my $chr = $temp[1];
my $start = $temp[2];
my $end = $temp[3];
my $len = $end - $start + 1;
my $refseq = getfastaseq($fasta);
if ($strand eq "+") {
	if (exists $refseq->{$chr}) {
		my $subseq = substr($refseq->{$chr}, $start-1, $len);  #(yliu) "-1"
		open FAS, ">$head.fasta" or die "$!";
		print FAS ">$head\n$subseq\n";
		close FAS;
	} else {
		print "$chr can not found in $fasta\n";
	}
} else {
	if (exists $refseq->{$chr}) {
		my $subseq = substr($refseq->{$chr}, $start-1, $len);  #(yliu) "-1"
#		$subseqrec = revcom($subseq);
		##########(yliu add)
		my @seqs = split(//, $subseq);
		@seqs = reverse @seqs;  # reverse seq
		my $seq_rev = join "", @seqs;
		$seq_rev =~ tr/agctAGCT/tcgaTCGA/;  # complement seq
		$subseqrec = $seq_rev;
		##########
		open FAS, ">$head.fasta" or die "$!";
		print FAS ">$head" . "_rc\n$subseqrec\n";
		close FAS;
	} else {
		print "$chr can not found in $fasta\n";
	}
}
}

####################
sub getfastaseq
{
$/=">";
my %hash;
my ($file) = @_;
open IN, "$file" or die "$!";
while (<IN>) {
	next if (length $_ < 2);
	my @unit = split("\n", $_);
	my $temp = shift @unit;
	my @temp1 = split(" ", $temp);
	my $head = $temp1[0];
	$head =~ s/\_//;
	my $seq = join("\n", @unit);
	$seq =~ s/\>//g;
	$seq =~ s/\n//g;
	$seq =~ s/\s//g;
#	print "$head\n";
	$hash{$head} = $seq;
}
close IN;
$/="\n";
return \%hash;
} 
