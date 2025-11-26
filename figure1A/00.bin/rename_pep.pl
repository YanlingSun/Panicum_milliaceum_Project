use strict;
use warnings;
use Data::Dumper;

die "Usage: comands: perl $0 input output\n" if (@ARGV != 2);
$/=">";
my %pep;
open FA, $ARGV[0] or die "$!";
while(<FA>){
   chomp; 
   next if($_ eq "");
   my @lines = split(/\n/,$_);
   my $head = shift @lines;
   my @temp = split/ +/,$head;
   my $id = $temp[0];
   my $seq = join"",@lines;
   my $seq_formated = &faFormat($seq,60);
   print ">$id\n$seq_formated";
}
$/="\n";
close FA;

sub faFormat(){
  my ($seq,$num)=@_;
  my @seq=split//,$seq;
  my ($string,$cnt);
  foreach(@seq){
   $cnt++;
   if($cnt%$num==0){$string.=$_."\n"}else{$string.=$_}
  }
  if($cnt%$num!=0){return $string."\n"}else{return $string}
}

