#!/usr/bin/perl
use Getopt::Long;
use FindBin qw($Bin);

GetOptions (\%opt,"table:s","flanking:s","ACT","reorder","project:s","help");

my $help=<<USAGE;
perl drawRegionPipe.pl --table test.inf --flanking 0 --reorder --ACT --project HEG4_SV_test/
--table: information table used to draw
OS	Chr1	2575898	2576036	OG	1	1905399	1917790	HEG4	Superscaffold1	1979832	1999309
OS	Chr1	2577382	2577394	OG	1	1905399	1917790	HEG4	Superscaffold1	1979832	1999309	OS	Chr5	6721766	6721996
--flanking: if get N of flanking sequence from both side
--reorder: if reorder the sequence order in the table. We put OG at first and do not move others.
--ACT: if draw ACT figure, if not set just do file convert
USAGE

if ($opt{help} or keys %opt < 1){
    print "$help\n";
    exit();
}

$opt{flanking} ||=0;
$opt{project} ||="test";
`mkdir $opt{project}`;
readtable($opt{table});

#############################################
#OS	chr01   9408106 9415703 OG	chr02   3731742 3739474
sub readtable
{
my ($file) = @_;
my %hash;
open IN, "$file" or die "$!";
while (<IN>) {
	chomp $_;
	next if ($_ =~ /^$/ or $_ =~ /^#/);
	my @unit = split(" ", $_);
	my @header;
#	my $title;
	for (my $i = 0; $i < @unit; $i += 4) {
		my $prefix = $unit[$i];
		my $chr = $unit[$i+1];
		$chr =~ s/\_//;
		my ($s, $e) = sort {$a <=> $b} ($unit[$i+2], $unit[$i+3]);
		$s = $s - $opt{flanking} > 0 ? $s - $opt{flanking} : 1;
		$e = $e + $opt{flanking};
		my $head = $prefix . "_" . $chr . "_" . $s . "_" . $e;
		push @header, $head;
#		$title = $head if ($i == 0);

		`perl ./scripts/getsubdata2genome.pl --strand + --genegff ~/pmi.genome/A/Pmiliaceum.ChrA.gff --tegff ~/pmi.genome/A/Pmiliaceum.ChrA.gff.TE --fasta ~/pmi.genome/genome/split.rm.chr/Pma.Chr.rm.fa --refhead $head` if ($prefix=~/PM/i);
		`perl ./scripts/getsubdata2genome.pl --strand + --genegff ~/PhalliiHAL_v2.1/annotation/PhalliiHAL_496_v2.1.gene_exons.gff3 --tegff ~/PhalliiHAL_v2.1/annotation/PhalliiHAL_496_v2.1.repeatmasked_assembly_v2.0.gff3 --fasta ~/PhalliiHAL_v2.1/assembly/PhalliiHAL_496_v2.0.hardmasked.fa --refhead $head` if ($prefix=~/PH/i);
		`perl ./scripts/getsubdata2genome.pl --strand + --genegff ~/pmi.genome/B/Pmiliaceum.ChrB.gff --tegff ~/pmi.genome/B/Pmiliaceum.ChrB.gff.TE --fasta ~/pmi.genome/genome/split.rm.chr/Pmb.Chr.rm.fa --refhead $head` if ($prefix=~/PM/i);


	}
	
	my @sorted_header = sort @header;  #(yliu) for good running of runblast2seq.pl, cause I reduce times of BLAST from (N*N) to [1+2+...+(N-1)]
	my $title = $sorted_header[0];  #(yliu) my new title, always is the first heaser(in alphabetical order)
		
	if ($opt{ACT}) {
		my $headers = join (",", @sorted_header);
		print "Headers: $headers\n";
		`perl ./act/runblast2seq.pl`;
		`perl ./act/run2act.pl`;
		`perl ./scripts/drawRegionNway-.pl --headers $headers --project $title`;
		`rm *.fasta.n* *.blast *.temp formatdb.log`;  # *.gene.embl
	}
	
	print "TEST\t$opt{project}\t$title\n";
	
	`if [ ! -d $opt{project}/$title ]; then mkdir $opt{project}/$title; fi`;
	`mv *.gff $opt{project}/$title`;
	`mv *.fasta $opt{project}/$title`;
	`mv *4ACT $opt{project}/$title`;
#	`mv *.embl $opt{project}/$title`;
#	`mv *.shell $opt{project}/$title`;

	`if [ ! -d $opt{project}/Fig ]; then mkdir $opt{project}/Fig; fi`;
	`mv *.svg $opt{project}/Fig`;
	`mv *.png $opt{project}/Fig`;
#	`mv *.pdf $opt{project}/Fig`;
}

close IN;
return \%hash;
}
