use Getopt::Long;
GetOptions (
	"indir:s" => \$indir,
	"sample:s"=> \$sample,
);
if (!$indir ||!$sample) {
        print STDERR <<USAGE;
=============================================================================
Descriptions: Generate shell scripts for DAS
Usage:
        perl $0 [options]
Options:
        * -indir         input dir
        * -sample        sample (A,B,C)
E.g.:
        perl $0 -indir <dir> -sample <A,B,C>
=============================================================================
USAGE
        exit;
}

@sample=split/,|;/,$sample;

open O1,">as.stat.xls";
print O1 "Events";
open O2,">as_gene.stat.xls";
print O2 "Gene";
@event=();

# merge as.stat.xls
for $s(@sample){
	open IN,"$indir/$s/$s.as.stat.xls" or die "Can't open file $s.as.stat.xls ";
	<IN>;
	while(<IN>){
		chomp;
		($as,$count)=split/\t/;
		$as{$as}{$s}=$count;
		if(!defined $h{$as}){
			push @event,$as;
			$h{$as}=1;
		}
	}
	close IN;
	print O1 "\t$s";
}
print O1 "\n";
# merge as_gene.stat.xls
for $s(@sample){
        open IN,"$indir/$s/$s.as_gene.stat.xls" or die "Can't open file $s.as_gene.stat.xls ";
        <IN>;
        while(<IN>){
                chomp;
                ($as,$count)=split/\t/;
                $as_gene{$as}{$s}=$count;
        }
        close IN;
	print O2 "\t$s";
}
print O2 "\n";
foreach $e(@event){
	print O1 "$e";
	print O2 "$e";
	for $s(@sample){
		print O1 "\t$as{$e}{$s}";
		print O2 "\t$as_gene{$e}{$s}";
	}
	print O1 "\n";
	print O2 "\n";
}
# merge as.xls
print "0Chr\tStart\tStrand\tGeneID\tSite\tType\tSplice_chain";
for $s(@sample){
	print "\t$s";
	open IN,"$indir/$s/$s.as.xls" or die "Can't open file $s.as.xls ";
	<IN>;
	while(<IN>){
		chomp;
		($gene,$site,$transcript,$structure,$type,$splice_chain)=split/\t/;
		$chr=(split/:/,$site)[0];
		$strand=(split/:|\(|\)/,$site)[2];
		$mark{$chr}{$strand}{$splice_chain}{$s}=1;
		@gene=split/;/,$gene;
		@site=split/;/,$site;
		for($i=0;$i<=$#gene;$i++){
			$site{$gene[$i]}=$site[$i];
			if(!defined $m{"$chr\t$strand\t$splice_chain"}{$gene[$i]}){
				$m{"$chr\t$strand\t$splice_chain"}{$gene[$i]}=1;
				$gene{"$chr\t$strand\t$splice_chain"}.="$gene[$i];";
			}
		}
		if(!defined $type{"$chr\t$strand\t$splice_chain"}){
			$type{"$chr\t$strand\t$splice_chain"}=$type;
			$sta{"$chr\t$strand\t$splice_chain"}=$sta;
		}
	}
	close IN;
}
print "\n";
foreach (sort keys %type){
	($chr,$strand,$splice)=split/\t/,$_;
	$gene{$_}=~s/;$//g;
	@gene=split/;/,$gene{$_};
	$s="";
	for $g(@gene){
		$s.=$site{$g}.";";
		$sta=(split/:|-/,$site{$g})[1];
		if(!defined $sta{$_}){
			$sta{$_}=$sta;
		}else{
			if($sta<$sta{$_}){
				$sta{$_}=$sta;
			}
		}
	}
	$s=~s/;$//g;
	print "$chr\t$sta{$_}\t$strand\t$gene{$_}\t$s\t$type{$_}\t$splice";
	for $s(@sample){
		if(!defined $mark{$chr}{$strand}{$splice}{$s}){
			$mark{$chr}{$strand}{$splice}{$s}=0;
		}
		print "\t$mark{$chr}{$strand}{$splice}{$s}";
	}
	print "\n";
}
=cut
foreach (sort keys %gene){
	@as=split/;/,$as{$gene{$_}};
	for $as(@as){
		$chr=(split/\t/,$sta{$_})[0];
		print "$sta{$_}\t$gene{$_}\t$_\t$type{$as}\t$as";
		for $s(@sample){
			if(!defined $mark{$chr}{$as}{$s}){
				$mark{$chr}{$as}{$s}=0;
			}
			print "\t$mark{$chr}{$as}{$s}";
		}
		print "\n";
	}
}
=cut
