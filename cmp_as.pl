$cmp=$ARGV[0];
($a,$b)=split/:/,$cmp;
open A,">$a-vs-$b.$a\_uni.xls";
open B,">$a-vs-$b.$b\_uni.xls";
open AB,">$a-vs-$b.overlap.xls";

open AS,"$ARGV[1]";
$head=<AS>;
chomp $head;
@head=split/\t/,$head;
$AB="$head[0]\t$head[1]\t$head[2]\t$head[3]\t$head[4]\t$head[5]\n";
$A="$head[0]\t$head[1]\t$head[2]\t$head[3]\t$head[4]\t$head[5]\n";
$B="$head[0]\t$head[1]\t$head[2]\t$head[3]\t$head[4]\t$head[5]\n";

for($i=6;$i<=$#head;$i++){
	if($a eq $head[$i]){
		$a_mark=$i;
	}
	if($b eq $head[$i]){
		$b_mark=$i;
	}
}
$a_uni=0;
$b_uni=0;
$ab=0;
$a_g=0;
$b_g=0;
$ab_g=0;
while(<AS>){
	chomp;
	@event=split/\t/;
	@gene=split/;/,$event[2];
	if($event[$a_mark]==1){
		if($event[$b_mark]==1){
			# overlap
			$ab++;
			for $g(@gene){
				if(!defined $ab{$g}){
					$ab_g++;
					$ab{$g}=1;
				}
			}
			$AB.="$event[0]\t$event[1]\t$event[2]\t$event[3]\t$event[4]\t$event[5]\n";
		}else{
			# a uni
			$a_uni++;
			for $g(@gene){
				if(!defined $a{$g}){
					$a_g++;
					$a{$g}=1;
				}
			}
			$A.="$event[0]\t$event[1]\t$event[2]\t$event[3]\t$event[4]\t$event[5]\n";
		}
	}else{
		if($event[$b_mark]==1){
			# b uni
			$b_uni++;
			for $g(@gene){
				if(!defined $b{$g}){
					$b_g++;
					$b{$g}=1;
				}
			}
			$B.="$event[0]\t$event[1]\t$event[2]\t$event[3]\t$event[4]\t$event[5]\n";
		}
	}
}

print A "# $a_g alternative splicing genes , $a_uni alternative splicing events\n$A";
print B "# $b_g alternative splicing genes , $b_uni alternative splicing events\n$B";
print AB "# $ab_g alternative splicing genes , $ab alternative splicing events\n$AB";

close AS;
close A;
close B;
close AB;
