use Data::Dumper;


#Checks to see if this is a completely unique of all species clade
#Receives an ever expanding array and a relationship to see if that
#Should enter the array
sub CheckOnlyClade{
	
	@trees = (); local *trees = $_[0];
	$Rel = ""; local *Rel = $_[1];
	$switch = "True";
	
	$unique_count = 0;
	$inner_count = 0;
	$conflict_count = 0;
	$diff = 0;
	#Decide what to do with the relationship
	#Cases are: 
	#1) It is unique so hold it for the next round
	#2) It is nested withing an existing relationship
	#3) An existing relationship is nested within it
	foreach $i (0..$#trees){
	
		%rel_comp = ();
		@array1 = split " ", $trees[$i];
		@array2 = split " ", $Rel;
		@rel_comp{@array2} = undef;
		delete @rel_comp{@array1};
		$rel_comp_size = (keys %rel_comp) - 1;
		$loss = $#array2 - $rel_comp_size;
		$diff = ($#array2+1) - (1+$#array1);
		$other_diff = ($#array1+1) - ($#array2+1);
		
		%tree_comp = ();
		@tree_comp{@array1} = undef;
		delete @tree_comp{@array2};
		$tree_comp_size = (keys %tree_comp) - 1;
		$tree_loss = $#array1 - $tree_comp_size;
		
		#1) Check if it has had something removed as it parses through the trees
		#If no taxa has ever been removed it should be unique and therefore unique
		#count goes up
		if($loss == 0){
			
			$unique_count++;
			
		}elsif($loss == ($#array1+1)){ 
		#2) if the unique count has not gone up check if it has decreased by the equivalent amount to
		#the number originally available in the relationship test ($#array1)
			$inner_count++;
			
		}elsif($tree_loss == ($#array2+1)){
			$inner_count++;
		}
	}
	#Unique conditions are met when it has never had something the same size which has had nothing removed
	#print "$unique_count\n";
	#print "$#trees\n";
	if(($inner_count+$unique_count) == ($#trees+1)){
		return $Rel;
	}else{
		#print "$inner_count\t$unique_count\n";
		#print "$Rel\n";
		#die;
	}

	#return $Rel;
}

#Assemble a consensus tree out of the relationships that are left

$TopLikely = "6454829.35";
$name = $ARGV[0];
if($ARGV[0] ne "go"){
	
	print "This annoying help menu appears to make sure it's run correct\n";
	print "This program should be in your folder EdgeLikelihoods/\n";
	print "If it is not please move or copy it there\n";
	print "once that is done go ahead and run the command:\n";
	print "perl Phlame.pl go\n";
	
}else{
	system("ls Likely* > Temp.txt");
	%RelHash = ();
	open(file, "Temp.txt")||die "System function not working to make temp.txt\n";
	while($files = <file>){
	
		chomp $files;
		@HeadArray = (); @SumArray = ();
		open(file2, "$files")||die "No Like files available";
		while($line = <file2>){
			
			chomp $line;
			@LikelyArray = ();
			if($line =~ /^Gene,/){
				
				@HeadArray = split ",", $line;
				shift @HeadArray;
				
			}else{
				
				@LikelyArray = split ",", $line;
				shift @LikelyArray;
				foreach $i (0..$#LikelyArray){
				
					$SumArray[$i] += $LikelyArray[$i];
				}
					
			}
		}
		foreach $i (0..$#HeadArray){
			
			$RelHash{$SumArray[$i]} = $HeadArray[$i];
		}
	}
	$count = 0; $clade = ""; @array = ();
	@children = (); @tree = (); @species = ();
	@trout = (); @likelihoods = ();
	foreach $keys (sort keys %RelHash){
		
		@array = split " ", $RelHash{$keys};
		
		#print "$keys\t$RelHash{$keys}\n";

		if($count == 0){
			
			push @tree, $RelHash{$keys};
			$t = $count+1;
			#print "$t\n";
			push @trout, $t;
			
		}else{
			
			$test = "";
			$test = CheckOnlyClade(\@tree, \$RelHash{$keys});
			if($test ne ""){
				
				push @tree, $RelHash{$keys};
				print "$keys\n";
				$t = $count+1;
				#print "$t\n";
				push @trout, $t;
			}
				
		}
		$count++;
	}

	
	#Assemble the best biparts
	$clade = ""; @clades = ();
	$numb = 0; %HASH = ();
	foreach $i (0..$#tree){
		
		print "$tree[$i]\n";
		@array = split " ", $tree[$i]; 
		$numb = ($#array + 1);
		$clade = $tree[$i];
	#	$HASH{$clade} = $numb;
		#print "($tree[$i]);\n";
	}
	#@double = (); $clade = ""; $count = 0;
	#for $keys (sort { $HASH{$b} <=> $HASH{$a} } keys %HASH){
		
		#print "$keys\n";
	#	$keys =~ s/ /,/g;
	#	if($count == 0){
	#		$clade = "($keys)";
	#	}else{
	#		$clade =~ s/$keys/\($keys\)/;
	#	}
	#	$count++;
	#}
	#print "$clade;\n";
	#print Dumper(\@clades);
}
