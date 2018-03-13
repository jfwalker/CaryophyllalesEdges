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


#Get the biparts of the tree so you know
#which conflicts to examine

sub GetConstraints {
	
	print StatsOut "#############################################\n";
	print StatsOut "Edges from your tree\n";
	print StatsOut "#############################################\n";
	$line = ""; $con = ""; @conflicts_array = ();
	$count = 0;
	open(bp_log_file, "temp/bp.log");
	while($line = <bp_log_file>){
		
		chomp $line;
		if($line =~ /CLADE/){
			
			$con = ($line =~ m/CLADE: (.*?) \t.*/)[0];
			$con =~ s/ /,/g;
			print StatsOut "($count) $con\n";
			push @conflicts_array, $con;
			$count++;
		}
		
	}
	
	return @conflicts_array;
	
}

sub GetConflicts {
	
	$conflict = ""; local *conflict = $_[0];
	@edges = ();
	push @edges, $conflict;
	open(log_file, "temp/ParsableTrees.log") || die "No log File";
	while($line = <log_file>){
	
		chomp $line;
		@array1 = (); @array2 = (); $bipart = "";
		if($line =~ /^CLADE/){
			
			$test = "false";
			#account for output of bp if no conflicts
			if($line =~ /FREQ/){
				$bipart = ($line =~ /^CLADE: (.*?) \tFREQ.*/)[0];
			}else{
				$bipart = ($line =~ /^CLADE: (.*)/)[0];
			}
			@array1 = split ",", $conflict;
			@array2 = split " ", $bipart;
			if($#array2 == $#array1){
				
				#make an empty hash
				%comp = ();
				#use values in array1 as undefined
				@comp{@array1} = undef;
				#if its in array2 delete is
				delete @comp{@array2};
				#get whats left to see if it's all gone
				$comp_size = keys %comp;
				if($comp_size == 0){
					$test = "true";
				}
				
			}	
		}
		if($test eq "true"){
			
			if($line =~ /COUNT/){
			
				if($line !~ /ICA/){
				
					$bipart = ($line =~ / \t (.*?) \tCOU.*/)[0];
					$bipart =~ s/ /,/g;
					push @edges, $bipart;
					
				}
				
			}
			
		}
	}
	return @edges;
}


open(Configure, "$ARGV[0]")||die "Please See Configure File\n";
while($line = <Configure>){
	
	if($line =~ /^pxrmt:/){
		$pxrmt = ($line =~ /.*?: (.*)/)[0];	
	}elsif($line =~ /^pxbp:/){
		$pxbp = ($line =~ /.*?: (.*)/)[0];	
	}elsif($line =~ /^raxml:/){
		$raxml = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^Species:/){
		$conflicting_node = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^outfile:/){
		$outfile = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^Supermatrix:/){
		$SuperMatrix = ($line =~ /.*?: (.*)/)[0]; 
	}elsif($line =~ /^PartsFile:/){
		$PartFile = ($line =~ /.*?: (.*)/)[0]; 
	}elsif($line =~ /^Set:/){
		$TreeFile = ($line =~ /.*?: (.*)/)[0]; 
	}elsif($line =~ /^Threads:/){
		$threads = ($line =~ /.*?: (.*)/)[0]; 
	}elsif($line =~ /^Test:/){
		$IsItATest = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^Verbose:/){
		$verbose  = ($line =~ /.*?: (.*)/)[0];	
	}elsif($line =~ /^Folder:/){
		$folder = ($line =~ /.*?: (.*)/)[0];	
	}elsif($line =~ /^secret:/){
		$secret = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^Topologies:/){
		$Topos = ($line =~ /.*?: (.*)/)[0];
	}elsif($line =~ /^support:/){
		$support = ($line =~ /.*?: (.*)/)[0];
	}
}

print "Creating an outfile called: $outfile\n";
open(StatsOut, ">$outfile")||die "You didn't specify an outfile\n";
system("rm -Rf temp/ EdgeConstraints/ Genes/ EdgeLikelihoods/ && mkdir temp");

@trees = ();
#system("pxrr -u -t $TreeFile -o temp/trees.unroot");
system("cp $TreeFile temp/trees.root");
open(Trees, "temp/trees.root")||die "No tree file";
@trees = <Trees>;
chomp @trees;
open(out, ">temp/tree")||die "no ability to make temp";
print out "$trees[0]\n";
system("$pxbp -t temp/trees.root -u | grep \"\(\" > temp/Unique.tre");
system("$pxbp -t temp/tree -v > temp/bp.log");

@conflicts_array = (); %taxa_hash = ();
@conflicts_array = GetConstraints();
foreach $i (0..$#conflicts_array){
	
	@array = ();
	@array = split ",", $conflicts_array[$i];
	foreach $j (0..$#array){
		$taxa_hash{$array[$j]} = $array[$j];
	}
}

system("pxbp -t temp/Unique.tre -v -c $support -o temp/ParsableTrees.log");

#Get all the conflicts associated with the constraints
@nodes = ();
foreach $i (0..$#conflicts_array){
	
	@edge = ();
	@edge = GetConflicts(\$conflicts_array[$i]);
	push @nodes, [@edge];
}


#Not my best work but loads up a folder called EdgeConstraints with
#constraint files
system("mkdir EdgeLikelihoods");
system("mkdir EdgeConstraints");
%temp = (); $taxa = "";
foreach $i (0..$#nodes){

	open(edgeout, ">EdgeConstraints/Edge$i");
	open(Lout, ">>EdgeLikelihoods/LikelyOutEdge$i");
	$tem = "";
	for $j (0..$#{$nodes[$i]}){
		
		$taxa = "";
		%temp = ();
		%temp = %taxa_hash;
		@array = split ",", $nodes[$i][$j];
		@temp{@array} = undef;
		for $keys (keys %temp){
			if($temp{$keys} ne ""){
				$taxa .= ",$temp{$keys}";
			}
		}
		print edgeout "(($nodes[$i][$j])$taxa);\n";
		$hold = ($nodes[$i][$j] =~ s/,/ /g);
		$tem .= "$nodes[$i][$j],";
	}
	print Lout "Gene,$tem\n";

}

#loc will store locations
@loc = (); @names = ();
($ref_l, $ref_t) = GetParts($PartFile, $IsItATest);
#@loc = @$ref_l;
#@names = @$ref_t;

#CountOfGenes is total to be analyzed
$CountOfGenes = 0;
$CountOfGenes = ($#loc+1);
print StatsOut "#############################################\n";
print StatsOut "Total genes: $CountOfGenes\n";
print StatsOut "#############################################\n";


system("mkdir Genes");

#Get the fasta into memory to make genes
%FastaHash = (); $count = 0; %TotalTaxaHash = ();
%FastaHash = ReadSuperMatrix(\$SuperMatrix);

#Create a folder full of genes
foreach $i (0..$#loc){
	
	open(GeneOut, ">Genes/$names[$i].fa");
	($start,$stop) = split "-", $loc[$i], 2;
	$dif = $stop - $start + 1;
	$to_remove = ""; $seq_count = 0;
	for $keys (sort keys %FastaHash){
		
		$seq = substr $FastaHash{$keys}, ($start-1), $dif;
		print GeneOut ">$keys\n$seq\n";
		
	}

}
system("ls Genes/* > ListOfGenes.txt");
#system("ls EdgeConstraints/* > ListOfEdgeConstraints.txt");
#Run RAxML with the constraints
@emoticons = ("(☞ﾟヮﾟ)☞ ", "☜(ﾟヮﾟ☜)","ヽ(´ー｀)ﾉ","(^o^)丿","(^O^)／","（^—^）","ヽ(^。^)ノ","(／ロ°)／","The emoticons make this Sciency", "ヽ(´ー｀)┌","(ﾟдﾟ)","（ ﾟ Дﾟ)");
open(GeneList, "ListOfGenes.txt")||die "No Genes selected";
while($line = <GeneList>){
	
	chomp $line;
	$count = 0;
	open(EdgeList, "ListOfEdgeConstraints.txt")||die "No Edges Identified";
	while($file = <EdgeList>){
	
		chomp $file;
		$name = ($file =~ m/.*?\/(.*)/)[0];
		$likely = "";
		open(Lout, ">>EdgeLikelihoods/LikelyOut$name");
		open(Tree, "$file")||die "Edges Lost\n";
		while($tree = <Tree>){
			chomp $tree;
			open(trout, ">temp.tre");
			print trout "$tree\n";
			system("$raxml -T $threads -p 12345 -m GTRGAMMA -g temp.tre -s $line -n hold | grep \"best tree\" > likelihood.txt");
			open(likelihood, "likelihood.txt");
			@like = <likelihood>;
			chomp @like;
			@like_array = split " ", $like[0];
			$emot = $emoticons[rand @emoticons];
			print "$emot \t$line,$file: $like_array[6]\n";
			$likely .= "$like_array[6],";
			system("rm RAxML_*");
		}
		print Lout "$line,$likely\n";
		$count++;
	}
}
system("rm ListOfEdgeConstraints.txt ListOfGenes.txt");
system("ls EdgeLikelihoods/* > LikelihoodFiles.txt");
$count = 0;
open(lik, "LikelihoodFiles.txt");
@files = ();
@file = <lik>;
chomp @file;
foreach $i (0..$#file){
	
	chomp $file;
	#Sum up the columns for likelihood values
	$name = ($file[$i] =~ m/.*?\/LikelyOut(.*)/)[0];
	print StatsOut "#############################################\n";
	print StatsOut "Summed Likelihoods for: $name\n";
	print StatsOut "#############################################\n";
	open(value, "$file[$i]")||die "No likelihood files calculated\n";
	@array = (); @array1 = (); @array2 = (); $count = 0;
	while($line = <value>){
		if($count == 0){
			
			@array2 = split ",", $line;
		}else{
			chomp $line;
			@array = split ",", $line;
			foreach $j (0..$#array){
				
				$array1[$j] += $array[$j];
			}
		}
		$count++;
	}
	@sorted = ();
	foreach $j (0..$#array1){
		
		print StatsOut "$array2[$j]\t$array1[$j]\n";

	}
	@sorted = sort {$a <=> $b} @array1;
	print StatsOut "Best is: $sorted[0]\n";

}




#system("rm -Rf temp");

