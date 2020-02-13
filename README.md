# AS-cmp
Compare the AS results analyzed by ASTALAVISTA software of different samples

perl merge_as.pl -indir indir -sample A,B,C,D |sort -k1,1 -k2,2n|perl -e 'while(<>){chomp;($chr,$sta,$info)=split/\t/,$_,3;$chr=~s/^0Chr/Chr/g;print"$chr\t$info\n";}' > as_merge.xls

perl cmp_as.pl A:B as_merge.xls
