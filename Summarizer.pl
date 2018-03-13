use Data::Dumper;
$count = 0;
@taxa = (DrobinSFB_Droseraceae_Drosera_binata,NepSFB_Nepenthaceae_Nepenthes_alata,MJM2940_Ancistrocladaceae_Ancistrocladus_robertsonianum,DrolusSFB_Drosophyllaceae_Drosophyllum_lusitanicum,MJM3209_Frankeniaceae_Frankenia_salina,Retr_Tamaricaceae_Reaumuria_trigyna,MJM3210_Plumbaginaceae_Limonium_californicum,MJM3333_Polygonaceae_Bistorta_bistortoides,MJM3167_Montiaceae_Montia_chamissoi,Slycopersicum_Outgroups_Solanum_lycopersicum,MJM2704_Achatocarpaceae_Achatocarpus_gracilis,GiphSFB_Gisekiaceae_Gisekia_pharnaceoides,PolmaSFB_Amaranthaceae_Polycnemum_majus,DBGStha_Stegnospermataceae_Stegnosperma_halimifolium,MJM2911_Cactaceae_Opuntia_arenaria,GypSFB_Caryophyllaceae_Gypsophila_repens,Beta_Chenopodiaceae_Beta_vulgaris,KeboSFB_Kewaceae_Kewa_bowkeriana,MJM1773_Sarcobataceae_Sarcobatus_vermiculatus,AncoSFB_Basellaceae_Anredera_cordifolia,PhaexSFB_Molluginaceae_Pharnaceum_exiguum,Mguttatus_Outgroups_Mimulus_guttatus,MJM1771_Nyctaginaceae_Mirabilis_multiflora,MacauSFB_Macarthuriaceae_Macarthuria_australis,Pool_Portulacaceae_Portulaca_oleracea_SRA,CVDF_Simmondsiaceae_Simmondsia_chinensis,MJM2726B_Amaranthaceae_Iresine_arbuscula,MJM2944_Didiereaceae_Decarya_madagascariensis,EDIT_Aizoaceae_Sesuvium_verrucosum,LimaeSFB_Limeaceae_Limeum_aethiopicum,MJM1651_Phytolaccaceae_Rivina_humilis,MJM1649_Phytolaccaceae_Ercilla_volubilis,YNFJ_Microteaceae_Microtea_debilis,MJM2669_Agdestidaceae_Agdestis_clematidea,GrakuSFB_Anacampserotaceae_Grahamia_kurtzii,RUUB_Physenaceae_Physena_madagascariensis,MJM1789_Talinaceae_Talinum_paniculatum);
#print Dumper(\@taxa);
open(file, $ARGV[0])||die "No File\n";
while($line = <file>){

	chomp $line;
	@array = split ",", $line;
	if($count == 0){

		@array1 = @array;

	}else{

		foreach $i (0..$#array){

			$array2[$i] += $array[$i];

		}
	}
	$count++;

}
%NEW_HASH = ();
foreach $i (1..$#array1){

	%HASH = (); @test = ();
	@test = split " ", $array1[$i];
	foreach $j (0..$#test){
		
		$HASH{$test[$j]} = $test[$j]; 
	}
	$ingroup = "(("; $outgroup = "";
	foreach $j (0..$#taxa){
		
		if(exists $HASH{$taxa[$j]}){
			
				$ingroup .= "$taxa[$j],"; 
		}else{
			
				$outgroup .= ",$taxa[$j]";
		}
	}
	$ingroup =~ s/,$//;
	$clade = "$ingroup)$array2[$i]$outgroup);";
	print "$array2[$i]\t$clade\n";
	$NEW_HASH{$array2[$i]} = $clade;
	#print "$array1[$i]: $array2[$i]\n";

}
foreach $keys (sort keys %NEW_HASH){
	
		print "$keys\t$NEW_HASH{$keys}\n";
}
#print Dumper(\@array2);
