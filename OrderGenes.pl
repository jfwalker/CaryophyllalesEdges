#Takes in a file with the genes by length and puts another file in that order
use Data::Dumper;
if($#ARGV != 1){
	
	print die "perl OrderGenes.pl FileToBeOrdered GenesByLengthFile\n";
}
$name = ""; %HASH = (); $rest = "";
open(file, $ARGV[0])||die "No File To match\n";
while($line = <file>){
	
	chomp $line;
	$name = ($line =~ m/(.*?)\.NoAt.*/)[0];
	$rest = ($line =~ m/.*?\.NoAt,(.*)/)[0];
	$HASH{$name} = $rest;
	
}
open(file2, $ARGV[1])||die "Missing By Length\n";
while($line = <file2>){
	
	chomp $line;
	$name = ($line =~ m/(.*?)\t.*/)[0];
	if(exists $HASH{$name}){
		
		print "$name,$HASH{$name}\n";
	}
}
