#!/usr/bin/perl
use strict;
use warnings;

die "Usage: comands: perl $0 input output\n" if (@ARGV != 2);
open IN, $ARGV[0] or die $!;
open OUT, ">", $ARGV[1] or die $!;

while (<IN>) {
   next if ($_ =~ /^#/ or $_ =~ /^scaffold/);
   my @lines = split(/\t/, $_);
      if ($lines[2] eq "mRNA") {
         chomp;
         my $chr = $lines[0];
         my $start = $lines[3];
         my $end = $lines[4];
         my $gene_name;
         if ($lines[8] =~ /^ID=(\S+);Parent=/) {$gene_name = $1}
            print OUT "$chr\t$gene_name\t$start\t$end\n";
      }
}


close IN;
close OUT;
