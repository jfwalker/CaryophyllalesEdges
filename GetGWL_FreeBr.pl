use Data::Dumper;

#This subroutine gets the different gene lengths
sub GetParts {
	
	@temp_array = ();
	@temp_array = @_;
	$PartFile = $temp_array[0];
	$IsItATest = $temp_array[1];
	$CountOfGenes = 0; @names = ();
	open(Parts, "$PartFile")||die "Can't Find Parts file";
	while($line = <Parts>){

		chomp $line;
		$location = ($line =~ m/.*? = (.*)/)[0];
		$name = ($line =~ m/DNA, (.*?) = .*/)[0];
		push @names, $name;
		#This can be used to specify only a few genes
		#CHANGE AFTER TESTING!!!!!!!!!!!!!!!!
		if($IsItATest eq "True"){
			if($CountOfGenes < 2){
				
				push @loc, $location;
		
			}else{}
		}else{
			push @loc, $location;
		}
		$CountOfGenes++;		
	}
	return (\@loc, \@names);
}

#Read in the Supermatrix
sub ReadSuperMatrix {
	
	
	$count = 0;
	$SuperName = ""; local *SuperName = $_[0];
    %FastaHash = (); $name = "";
    $seq = "";
    #print "$SuperName\n";
    open(Supermatrix, "$SuperName");
	while($line = <Supermatrix>){
		
		chomp $line;
		if($line =~ /^>/){
			if($count != 0){
				
				$FastaHash{$name} = $seq;
			}
			$name = ($line =~ m/>(.*)/)[0];
			$seq = "";
		}else{
			$seq .= $line;
		}
		$count++;
	}
	$FastaHash{$name} = $seq;
	return %FastaHash;	
}

if($#ARGV != 3){
	
		print "perl GetGWL_FreeBr.pl Supermatrix Parts TreeFile Outfile\n";
		die;
	
}

system("rm RAxML_*");
$SuperMatrix = $ARGV[0];
$PartFile = $ARGV[1];
$TreeSet = $ARGV[2];
open(StatsOut, ">$ARGV[3]");



@loc = (); @names = ();
($ref_l, $ref_t) = GetParts($PartFile, $IsItATest);
@loc = @$ref_l;
@names = @$ref_t;

#CountOfGenes is total to be analyzed
$CountOfGenes = 0;
$CountOfGenes = ($#loc+1);
#print StatsOut "#############################################\n";
#print StatsOut "Total genes: $CountOfGenes\n";
#print StatsOut "#############################################\n";

%FastaHash = (); $count = 0; %TotalTaxaHash = ();
%FastaHash = ReadSuperMatrix(\$SuperMatrix);
@emoticons = ("(☞ﾟヮﾟ)☞ ", "☜(ﾟヮﾟ☜)","ヽ(´ー｀)ﾉ","(^o^)丿","(^O^)／","（^—^）","ヽ(^。^)ノ","(／ロ°)／","The emoticons make this Sciency", "ヽ(´ー｀)┌","(ﾟдﾟ)","（ ﾟ Дﾟ)");

foreach $i (0..$#loc){
	
	open(GeneOut, ">$names[$i].fa");
	($start,$stop) = split "-", $loc[$i], 2;
	$dif = $stop - $start + 1;
	for $keys (sort keys %FastaHash){
		
		$seq = substr $FastaHash{$keys}, ($start-1), $dif;
		print GeneOut ">$keys\n$seq\n";
		
	}
	
	
	#Edit system specific hereye
	system("raxmlHPC -f g -T 3 -p 12345 -m GTRGAMMA -z $TreeSet -s $names[$i].fa -n hold | grep \"Tree \" > likelihood.txt");
	open(file, "likelihood.txt")||die "Something with raxml not working\n";
	@temp_array = ();
	$acount = 0;
	while($line = <file>){
		
		chomp $line;
		$temp = ($line =~ m/.*?: (.*)/)[0];
		push @temp_array, $temp;
		$all .= ",Tree$acount";
		$acount++;
	}
	if($i == 0){
		
		print StatsOut "GeneName,Free$all\n";
	}
	system("rm RAxML_*");
	system("raxmlHPC -T 2 -p 12345 -m GTRGAMMA -s $names[$i].fa -n hold | grep \"best tree\" > likelihood.txt");
	$cat = "";
	$cat = $names[$i];
	open(likelihood, "likelihood.txt");
	@like = <likelihood>;
	chomp @like;
	@like_array = split " ", $like[0];
	$emot = $emoticons[rand @emoticons];
	print "$emot\t$names[$i]\t$like_array[6]\n";
	$cat .= ",$like_array[6]";
	foreach $j (0..$#temp_array){
		$emot = $emoticons[rand @emoticons];
		print "$emot\t$names[$i]\t$temp_array[$j]\n";
		$cat .= ",$temp_array[$j]";
	}
	print StatsOut "$cat\n";
	system("rm $names[$i].fa RAxML_* likelihood.txt");
}
