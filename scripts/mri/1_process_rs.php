#!/usr/bin/php
<?php
	$dataDir = "";
	$processedDir = "";

	$rats = array(2,3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41);
	$times = array(1,10);

	foreach ($times as $time)
	{
		foreach($rats as $rat)
		{
	print "We are processing rat ".$rat." timepoint " .$time . "\n";
	$inputDir = $dataDir ."/rat-".$rat ."-time-" .$time;
	$outputDir = $processedDir ."/rat-". $rat ."-time-" .$time;

	//Remove first 20 images to ensure steady-state
	$input = $inputDir ."/rs.nii.gz";
	$output = $inputDir ."/rs_830.nii.gz";
	if(file_exists($input) )
	{
		system("fslroi $input $output 20 850");
	}

	//change spacing
	# use 'exec' and not 'system' to prevent echoing of the output
			$sizeType = exec( "human_or_rat.php -i $output" );

			# only multiply voxels with 10 if size type is 'rat'.
			if( file_exists($output ) && $sizeType == 'rat' )
			{
				system( "changespacing -i $output -m 10" );
			}
	
	//Motion correction
	$motionInput1 = $output;
	$motionOutput1 = $outputDir ."/rs_830_mc.nii.gz";
	if(file_exists($motionInput1) )
	{
		system("mcflirt -in $motionInput1 -out $motionOutput1 -spline_final -meanvol -stats -plots -report");
	}
	
	//Calculate the mean of the rs for registration/mask purposes
	$meanInput1 = $motionOutput1;
	$meanOutput1 = $outputDir ."/rs_830_mean_mc.nii.gz";
		if(file_exists($meanInput1) )
	{
		system("fslmaths ". $meanInput1 ." -Tmean ". $meanOutput1);
	}
	

	//Inhomogeneity correction
	$n3Input1 = $meanOutput1;
	$n3Output1 = $outputDir ."/rs_830_mean_mc_n3.nii.gz";
	$fwhm = 1.5;
	$shrinkfactor = "4 4 2";
	if(file_exists($n3Input1) )
	{
		system("n3 --fwhm $fwhm --shrink-factor $shrinkfactor -i $n3Input1 -o $n3Output1");
	}
	
	//BET: You can change the values of radius, f and center of gravity (determined with fslstats -C)
	$betInput1 = $n3Output1;
	$betOutput1 = $outputDir ."/rs_830_mean_n3_bet.nii.gz";
	$radius = 80;
	$f = 0.7;
	$center = "33 9 42";
	if(file_exists($betInput1) )
	{
		//Change voxel-size z-direction for an easier brain extraction
		system("dividespacing -i $betInput1 -d 2 -m 2.0");
		system("bet $betInput1 $betOutput1 -r $radius -f $f -c $center -R");
	}
	if(file_exists($betOutput1))
	{
		//Make sure to change voxel-size z-direction back!
		system("dividespacing -i $betInput1 -d 2 -m 0.5");
		system("dividespacing -i $betOutput1 -d 2 -m 0.5");
	}
	
	//Make mask from BET
	$maskInput1 = $betOutput1;
	$maskOutput1 = $outputDir ."/rs_830_mean_mc_n3_mask.nii.gz";
	if(file_exists($maskInput1))
	{
		system("fslmaths ". $maskInput1 ." -bin ". $maskOutput1);
	}
	
	}
}
?>

