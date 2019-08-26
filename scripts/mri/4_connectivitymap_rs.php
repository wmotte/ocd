#!/usr/bin/php
<?php
	$dataDir = "/";
	$processedDir = "";

	$rats = array(2,3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41);
	$times = array(1,10);
	foreach ($rats as $rat)
	{
		foreach ($times as $time)	
		{
		print "We are exctracting the ROIs in rat " .$rat ." restingstate " .$time ."\n";
		
		//Extract single ROIs from file containing several ROIs in individual resting-state space (after registrations!)
		$input = $dataDir ."/masked_ROIs_basic_in_rat" .$rat ."_in_rs" .$time ."_space.nii.gz";
		$output1 = $processedDir ."/left_frontal_cortex_in_rat" .$rat ."_in_rs" .$time ."_space.nii.gz";
		$output2 = $processedDir ."/right_striatum_in_rat" .$rat ."_in_rs" .$time ."_space.nii.gz";
		if(file_exists($input) &&! file_exists($output1) &&! file_exists($output2))
			{
			system("fslmaths " .$input ." -thr 1 -uthr 1 " .$output1);
			system("fslmaths " .$input ." -thr 4 -uthr 4 " .$output2);
			}
		}
	}



	$dataDir = "";
	$processedDir = "";

	$rats = array(2,3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41);
	$times = array(1,10);
	foreach ($rats as $rat)
	{
		foreach ($times as $time)	
		{
		print "We are calculating the fcmap without global mean regression of " .$rat ." \n";

		//Use filtered data as input
		$input = $dataDir ."/rs_830_filtered_and_motion_parameters_regressed.nii.gz";

		//Calculate connectivity maps for single ROIs to check quality of resting-state scans
		$roi1 = $processedDir ."/left_frontal_cortex_in_rat" .$rat ."_in_rs" .$time ."_space.nii.gz";
		$roi2 = $processedDir ."/right_striatum_in_rat" .$rat ."_in_rs" .$time ."_space.nii.gz";
		
		$output1 = $processedDir ."/connectivity_map_lh_frontal_cortex_in_rat" .$rat ."_time" .$time .".nii.gz";
		$output2 = $processedDir ."/connectivity_map_rh_striatum_in_rat" .$rat ."_time" .$time .".nii.gz";
		
		//Connectivitymaps with Fisher's-Z correlation coefficient
		if(file_exists($input) && file_exists($roi1) && file_exists($roi2))
			{
			system("nice fcmap -i $input -l $roi1 -o $output1 -z TRUE");
			system("nice fcmap -i $input -l $roi2 -o $output2 -z TRUE");
			}
		}
	}

?>
