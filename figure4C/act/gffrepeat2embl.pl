#!/usr/bin/perl
use Getopt::Long;

GetOptions (\%opt,"repeat:s","embl:s","title:s","help");


my $help=<<USAGE;
add gff format of repeat annotation to embl file
Run: perl $0 -repeat FF.repeatmasker.gff -embl test.embl -title FF

USAGE

if ($opt{help} or keys %opt < 1){
    print "$help\n";
    exit();
}

my %repeat;
open IN, "$opt{repeat}" or die "can not open my infile";
while(<IN>){
  chomp $_;
  next if ($_ eq "");
  next if ($_=~/^#/);
  my @fig=split("\t", $_);
	$fig[8] =~/ID=(.+)\;/;
    my $id=$1;
    my $coord;
	if($fig[6]eq "+"){
		$coord="$fig[3]..$fig[4]";
	}elsif($fig[6] eq "-"){
		$coord="complement($fig[3]..$fig[4])";
	}else{$coord="$fig[3]..$fig[4]"}
     $part1="FT   $fig[2]             $coord\n";
     $part2="FT                   /rpt_family=\"$fig[1]\"\n";
     $part3="FT                   /rpt_name=\"$id\"\n";
     $part="$part1$part2$part3";
     $repeat{$unit[5]}=$part;
}
close IN;

my $genenumber=0;
my @gene;
open EMBL, "$opt{embl}" or die "can not open my infile2";
while (<EMBL>) {
        if ($_=~/\smRNA\s/) {
           $genenumber++;
           if (length $gene[$genenumber] > 0) {
               $gene[$genenumber].=$_;
           }else{
               $gene[$genenumber]=$_;
           }
        }elsif($_=~/^SQ\s/){
           $genenumber++;
           if (length $gene[$genenumber] > 0) {
                $gene[$genenumber].=$_;
           }else{
                   $gene[$genenumber]=$_;
           }
        }else{
           if (length $gene[$genenumber] > 0) {
               $gene[$genenumber].=$_;
           }else{
               $gene[$genenumber]=$_;
           }
        }
}
close EMBL;
$l=@gene;
$header=shift @gene;
$tail=pop @gene;

my %cds;
foreach (@gene) {
    print "$_\n";
    if ($_=~/join\((\d+)\.\./) {
        $cds{$1}=$_;
    }else{
        print "Not pass $_\n";
    }
}

%hash=(%repeat,%cds);
my @start=sort {$a <=> $b} keys %hash;

open ME, ">$opt{title}.merge" or die "can not open my outfile";
print ME "$header";
foreach  (@start) {
        print ME "$hash{$_}";
}
print ME "$tail";
close ME;

