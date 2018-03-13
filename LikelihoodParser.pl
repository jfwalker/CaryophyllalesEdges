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
	#Decide what to do with the relationship
	#Cases are: 
	#1) It is unique so hold it for the next round
	#2) It is nested withing an existing relationship
	#3) An existing relationship is nested within it
	foreach $i (0..$#trees){
	
		%comp = ();
		@array1 = split " ", $trees[$i];
		@array2 = split " ", $Rel;
		@comp{@array2} = undef;
		delete @comp{@array1};
		$comp_size = keys %comp;
	
		#1) Check if it has had something removed as it parses through the trees
		#If no taxa has ever been removed it should be unique

		if($comp_size == ($#array2+1)){
			
			$unique_count++;
		}
		#2) Check if it is nested within and does not have any conflicts, for this that requires that for each one
		#non of them shrunk the bipartition anything less than the all the taxa
		
	}
	#Unique conditions are met when it has never had something the same size which has had nothing removed
	#print "$unique_count\n";
	#print "$#trees\n";
	if($unique_count == ($#trees+1)){
		return $Rel;
	}

	#return $Rel;
}


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

	foreach $keys (sort keys %RelHash){
		
		@array = split " ", $RelHash{$keys};
		
		#print "$keys\t$RelHash{$keys}\n";

		if($count == 0){
			
			push @tree, $RelHash{$keys};
			
		}else{
			
			$test = "";
			$test = CheckOnlyClade(\@tree, \$RelHash{$keys});
			if($test ne ""){
				
				push @tree, $RelHash{$keys};
			}
				
		}
		$count = 1;
	}
	print Dumper(\@tree);
}
