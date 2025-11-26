#!/usr/bin/perl
use Getopt::Long;
use SVG;

GetOptions (\%opt,"headers:s","project:s","help");

my $help=<<USAGE;
Draw N way using ACT files. Modify the head in \@feature.
perl $0 --headers --project 
USAGE

if ($opt{help} or keys %opt < 1) {
	print "$help\n";
	exit();
}

$opt{project} ||= "test";  #(yliu)if there is no "--project", then $opt{project} = "test"

our $height = 500;
our $width = 1000;
my $svg = SVG->new(width=>$width, height=>$height);

### common value
# my $rate = 100000/600; ### kb/width
# my @feature=("OBa_chr01_16242408_16304946","OG_chr01_15749793_15790854","rice_chr01_21924848_21992308","rice_chr09_12871954_12916016");
my @feature = split(",", $opt{headers});
my $maxlen = maxlen(@feature);
my $rate = ($maxlen + 0.2 * $maxlen) / 500;  # width(kb)
print "MAX: $maxlen\nRATE: $rate\n";

### draw chromosome feature
my $firstx=265;  # x of first chromosome
my $firsty=75;  # y of first chromosome
my $yinterval=110;   # interval between very chromosome, adjust with the number of chromosome to draw

for(my $i = 0; $i < @feature; $i++) {
	my $width = getfastalen("$feature[$i].fasta")/$rate;
	my $xx1 = $firstx;
	my $xx2 = $xx1 + $width;
	my $yy1 = $firsty + $i * $yinterval;
	if (-f "$feature[$i].gene.gff") {
		my $genegff = parseGFF("$feature[$i].gene.gff");
		$svg = drawXgene($svg, $genegff, $rate, $xx1, $xx2, $yy1, $feature[$i]);
	}
	if (-f "$feature[$i].te.gff") {
		my $tegff = parseTEGFF("$feature[$i].te.gff");
		$svg = drawXTE($svg, $tegff, $rate, $xx1, $yy1);
	}
}

### draw chromosome links
my $bary;
for(my $i = 1; $i < @feature; $i++){
	my $act = $feature[$i-1] . "VS" . $feature[$i] . "4ACT";
	my $h1 = ($i - 1) * $yinterval + $firsty + 15;
	my $h2 = $i * $yinterval + $firsty - 15;
	$bary = $h2 + 80;  # legend y
	drawlinkACT($act, $rate, $h1, $h2);
}

### draw scale bar
my $barx1 = 700;
my $barx2 = $barx1 + 100000 / $rate;
my $scalebar = $svg->line(
			x1 => $barx1, y1 => $bary - 3,
			x2 => $barx2, y2 => $bary - 3,
			style => {stroke => 'black'}
);
my $scale = $svg->text(
			x => $barx2 + 5, y => $bary,
			style => {'font-size' => '25%', 'text-anchor' => 'start', 'font-weight' => '100'}
) -> cdata("100 Kb");

$svg = legend($svg, $barx1 - 80, $bary, "GENE", "black");
$svg = legend($svg, $barx1 - 160, $bary, "TE", "blue");  # orange

my $outfile = "$opt{project}.svg";
writesvg($outfile, $svg);

############################################################

###############
sub legend
{
my ($svg, $x, $y, $name, $color) = @_;
my $xtext = $x + 15; 
$svg -> rectangle(
			x => $x, y => $y - 7,
			width => 10, height => 8,
			style => {fill => $color}
);
$svg -> text(
			x => $xtext, y => $y,
			style=>{'font-size' => '25%', 'text-anchor' => 'start', 'font-weight' => '100'}
) -> cdata($name);
return $svg;
}

###############
sub maxlen
{
my (@header) = @_;
my $max = 0;
for(my $i = 0; $i < @header; $i++) {
	my $fa = $header[$i] . ".fasta";
	my $len = getfastalen($fa);
	$max = $len > $max ? $len : $max;
}
return $max;
}

###############
sub drawlinkACT
{
my ($act, $rate, $h1, $h2) = @_;
my $identity = 80;  #
my $lencut = 100;  #
my @links;
open IN, "$act" or die "$!";
while (<IN>) {
	chomp $_;
	next if ($_ eq "");
	my @array = split(" ", $_);
	if ($array[1] >= $identity and $array[3] - $array[2] > $lencut ){
		push (@links, "$array[2]\t$array[3]\t$array[5]\t$array[6]");
	}
}
close IN;

foreach (@links) {
	my @unit = split("\t",$_);
	my $qleft = $unit[0] / $rate + 265;
	my $qright = $unit[1] / $rate + 265;
	my $tleft = $unit[2] / $rate + 265;
	my $tright = $unit[3] / $rate + 265;
	my $color;
	if ($tright > $tleft) {
		$color = 'red';  #as you wish
	} else {
		$color = 'blue';
	}

	my $qheight = $h1;
	my $theight = $h2;
	my $xv = [$qleft, $qright, $tright, $tleft];
	my $yv = [$qheight, $qheight, $theight, $theight];
	my $points = $svg -> get_path(
				x => $xv, y => $yv,
				-type => 'polyline',
				-closed => 'true'
	);
	my $tag = $svg -> polyline(
				%$points,
				style=>{fill => $color}
	);
}
}

###############
sub drawXgene
{
my ($svg, $refgenegff, $rate, $x1, $x2, $y, $head) = @_;
print "Start:$x1\tEnd:$x2\n";
my $strandline = $svg -> line(
			x1 => $x1, y1 => $y,
			x2 => $x2, y2 => $y,
			style => {stroke => 'black'}
);
my $title = $svg -> text(
			x => $x1 - 205, y => $y, 'font-size' => '30%'
) -> cdata("$head");

foreach my $g (keys %$refgenegff) {
	my @line = split("\n", $refgenegff -> {$g});
	my @pos;
	my $strand;
	foreach my $e (@line) {
		my @unit = split("\t",$e);
		if ($unit[2] eq "mRNA") {
			$strand = $unit[6];
		} else {
			push (@pos, [$unit[3], $unit[4]]);
		}
	}
	@pos = sort {$a->[0] <=> $b->[1]} @pos;
	my $gstart = $pos[0][0] / $rate + $x1;
	my $gend = $pos[$#pos][1] / $rate + $x1; 
	if ($strand eq "+") {
		my $geneline = $svg -> line(
					x1 => $gstart, y1 => $y - 6,
					x2 => $gend, y2 => $y - 6,
					style => {stroke => 'black'}
		);
		foreach my $e (sort {$a->[0] <=> $b->[1]} @pos) {
			my $start = $e->[0] / $rate + $x1;
			my $elen = ($e->[1] - $e->[0] + 1) / $rate;
			my $exony = $y - 10;
			my $exon = $svg -> rectangle(
						x => $start, y => $exony,
						width => $elen, height => 8,
						style => {fill => 'black'}
			);
		}
	} else {
		my $geneline = $svg->line(
					x1 => $gstart, y1 => $y + 6,
					x2 => $gend, y2 => $y + 6,
					style => {stroke => 'black'}
		);
		foreach my $e (sort {$a->[0] <=> $b->[1]} @pos) {
			my $start = $e->[0] / $rate + $x1;
			my $elen = ($e->[1] - $e->[0] + 1) / $rate;
			my $exony = $y + 2;
			my $exon = $svg->rectangle(
						x => $start, y => $exony,
						width => $elen, height => 8,
						style => {fill => 'black'}
			);
		}
	}
}
return $svg;
}

###############
sub drawXTE
{
my ($svg, $reftegff, $rate, $x1, $y) = @_;
foreach my $te (keys %$reftegff) {
	my @line = split("\t", $reftegff->{$te});
	my $gstart = $line[3] / $rate + $x1;
	my $gend = $line[4] / $rate + $x1;
	my $strand = $line[6];
#	my $type = $1 if ($line[8] =~ /Class=(.*?);/);
	my $color = "blue";  #orange
	if ($strand eq "+"){
		my $qleft = $gstart;
		my $qright = $gend;
		my $tright = $gend;
		my $tleft = $gstart;
		my $qheight = $y - 2;
		my $theight = $y - 10;
		my $xv = [$qleft, $qright, $tright, $tleft];
		my $yv = [$qheight, $qheight, $theight, $theight];
		my $points = $svg -> get_path(
					x => $xv, y => $yv,
					-type => 'polyline',
					-closed => 'true'
		);
		my $tag = $svg -> polyline(
					%$points,
					style => {fill => $color}
		);
    } elsif($strand eq "-") {
		my $qleft = $gstart;
		my $qright = $gend;
		my $tright = $gend;
		my $tleft = $gstart;
		my $qheight = $y + 2;
		my $theight = $y + 10;
		my $xv = [$qleft, $qright, $tright, $tleft];
		my $yv = [$qheight, $qheight, $theight, $theight];
		my $points = $svg -> get_path(
					x => $xv, y => $yv,
					-type => 'polyline',
					-closed => 'true'
		);
		my $tag = $svg -> polyline(
					%$points,
					style => {fill => $color}
		);
	} else {
		my $qleft = $gstart;
		my $qright = $gend;
		my $tright = $gend;
		my $tleft = $gstart;
		my $qheight = $y;
		my $theight = $y;
		my $xv = [$qleft, $qright, $tright, $tleft];
		my $yv = [$qheight, $qheight, $theight, $theight];
		my $points = $svg -> get_path(
					x => $xv, y => $yv,
					-type => 'polyline',
					-closed => 'true'
		);
		my $tag = $svg -> polyline(
					%$points,
					style => {fill => $color}
		);
	}
}
return $svg;
}

###############
sub getfastalen
{
$/ = ">";
my %hash;
my $len;
my ($file) = @_;
open IN, "$file" or die "$!";
while (<IN>) {
	next if (length $_ < 2);
	my @unit = split("\n", $_);
	my $temp = shift @unit;
	my @temp1 = split(" ", $temp);
	my $head = $temp1[0];
	my $seq = join("\n", @unit);
	$seq =~ s/\>//g;
	$seq =~ s/\n//g;
	$seq =~ s/\s//g;
	$len = length $seq;
}
$/ = "\n";
return $len;
}

###############
sub parseGFF
{
my ($gff) = @_;
my %hash;  # hash to store every record by key of Seq_id
my $seq;  # Scaffold
my $id;  # ID for element
my $record;  # all line for this record
my $index;  # key, Seq_id
open IN, "$gff" or die "$!";
while (<IN>) {
	chomp $_;
	next if ($_ =~ /^#/);
	my @unit = split("\t",$_);
	if ($unit[2] =~ /mRNA/) {
		$seq = $unit[0];
		if ($unit[8] =~ /ID=(.*?);/ or $unit[8] =~ /ID=(.*)/) {
			$id=$1;
		}
		$record = "$_\n";
		$hash{$id} = $record;
	} elsif($unit[0] eq $seq and $unit[8] =~ /Parent=$id/ && $unit[2] !~/intron/i) {
		$hash{$id} .= "$_\n";
	}
}
close IN;
return \%hash;
}

###############
sub parseTEGFF
{
my ($gff) = @_;
my %hash;  # hash to store every record by key of Seq_id
my $seq;  # Scaffold
my $id;  # ID for element
my $record;  # all line for this record
my $index;  # key, Seq_id
open IN, "$gff" or die "$!";
while (<IN>) {
	chomp $_;
	next if ($_ =~ /^#/);
	my @unit = split("\t",$_);
	if ($unit[8] =~ /ID=(.*?);/ or $unit[8] =~ /ID=(.*)/) {
		$id = $1;
		$hash{$id} = "$_";
	}
}
close IN;
return \%hash;
}

############### sub for write svg to file
sub writesvg {
my ($file, $svg) = @_;
open OUT, ">$file" or die "can not open my file";
print OUT $svg -> xmlify;
close OUT;
system `/home/jfchen/159/FFproject/tools/draw/svg2xxx_release/svg2xxx $file -t png -dpi 300 -m 10000000`;
}
