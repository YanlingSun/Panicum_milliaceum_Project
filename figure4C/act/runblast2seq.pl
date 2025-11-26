opendir DIR, "./" or die "can not open my dir";
my $num = 0;
foreach my $file (readdir DIR) {
	if ($file=~/(.*)\.fasta/) {
		print "$file\n";
		push (@filename,$1);
		system "formatdb -i $file -p F";
		$num ++;  #(yliu) get the num of files
	}
}
my @seq = sort @filename;
close DIR;

for(my $i=0; $i<$num; $i++) {
	for(my $j=$i+1; $j<$num; $j++) {
		system "blastall -p blastn -a 24 -U -F F -i $seq[$i].fasta -d $seq[$j].fasta -o $seq[$i]VS$seq[$j].blast -e 1e-5";  #(yliu) change the E-value as you wish
		print "$i\t$j\n"; 
   }
}








