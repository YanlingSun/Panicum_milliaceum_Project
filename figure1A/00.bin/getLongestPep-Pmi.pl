use strict;
use warnings;
use Data::Dumper;

#USAGE: perl $0 in.fa >out.fa
$/=">";
my %pep;
open FA, $ARGV[0] or die "$!";
while(<FA>){
   chomp; 
   next if($_ eq "");
   my @box = split(/\n/,$_);
   my $head = shift @box;
   my @temp = split/\./,$head;
   my $id = $temp[0];
   my $as_number = $temp[1];
   my $seq = join"",@box;
   my $len = length($seq);

   $pep{$id}->{$as_number}=$seq;  
}
$/="\n";
close FA;

foreach my $geneid(keys %pep){
  my $max_as_id;
  my $max_len = 0;
  my $max_seq;
  foreach my $as_id(keys %{$pep{$geneid}}){
     my $len = length($pep{$geneid}->{$as_id});
     if($max_len < $len){$max_len = $len; $max_as_id = $as_id;$max_seq = $pep{$geneid}->{$as_id}}
  }
  my $seq_formated = &faFormat($max_seq,60);
  print ">$geneid\.$max_as_id\n$seq_formated";
}
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
