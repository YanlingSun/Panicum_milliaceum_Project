#file=Pmi.TE.div
file=Pmi.LTR.div

# 0-50
for((i=0;i<=99;i++)); 
do 
   a=`awk -v var="$i" 'BEGIN{print var/2}'`; 
   b=`awk -v var="$a" 'BEGIN{print var+0.5}'`; 

   echo -n -e "A\t349642843\t$b\t";
   cat $file |awk -v left="$a" -v right="$b" '{if ($2 > left && $2 <= right) print $0}' |grep "A" -c; 

   echo -n -e "B\t454383302\t$b\t";
   cat $file |awk -v left="$a" -v right="$b" '{if ($2 > left && $2 <= right) print $0}' |grep "B" -c;

done

# >50
echo -n -e "A\t349642843\t50.5\t";
cat $file |awk '{if ($2 > 50) print $0}' |grep "A" -c;

echo -n -e "B\t454383302\t50.5\t";
cat $file |awk '{if ($2 > 50) print $0}' |grep "B" -c;

