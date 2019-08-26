#!/usr/bin/php
<?php
	$dataDir = "";
	$processedDir = "";

	$rats = array(2,3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41);
	$times = array(1,10);

	foreach ($rats as $rat)
	{
		foreach($times as $time)
		{
		print "We are processing rat ".$rat." timepoint " .$time . "\n";
		$inputDir  = $dataDir ."/rat-" .$rat ."-time-" .$time;
				
		$input = $inputDir ."/rs_830_mc_masked.nii.gz";
		$output = $processedDir ."/rs_830_motion_parameters_regressed";
		$mask = $inputDir ."/rs_830_mean_mc_n3_mask.nii.gz";
		$motion = $inputDir ."/rs_mc.nii.gz.par"; 
		$mean = $inputDir ."/rs_mean_mc.nii.gz";

		//Regression of motion-parameters. fsl_glm removes the mean, so you can add the mean afterwards again
		if(file_exists($input) && file_exists($motion))
			{
			system("nice fsl_glm --demean -i $input -d $motion -m $mask --out_res=$output");
			system("fslmaths " .$output ." -add " .$mean ." " .$output);
			}

		//To filter in afni, you need to make sure the 4th voxel dimension is the right TR!
		$outputnifti = $processedDir ."/rs_830_motion_parameters_regressed.nii.gz";
		$TR1 = $processedDir ."/rs_830_motion_parameters_regressed_TR_correct.nii";
		$inputnifti = $processedDir ."/rs_830_motion_parameters_regressed.nii";
		$TR2 = $processedDir ."/rs_830_motion_parameters_regressed_TR_correct.nii.gz";
		
		//Make sure there are no files present already		
		if(file_exists($copy))
			{
			system("rm $TR1");
			}

		if(file_exists($copy2))
			{
			system("rm $TR2");
			}

		//Change pixdim 4 to TR
		if(file_exists($outputnifti) &&! file_exists($copy2))
			{		
			system("gunzip $outputnifti");
			system("nifti_tool -prefix $TR1 -infiles $inputnifti -mod_hdr -mod_field pixdim '0 8.0 8.0 8.0 0.700 0 0 0' ");
			system("gzip $inputnifti");
			system("gzip $TR1");
			}

		//Filter rs data in AFNI with a bandpass filter between 0.01 and 0.1 Hz
		
		$filtered = $processedDir ."/rs_830_filtered_and_motion_parameters_regressed.nii.gz";
		
		
		if(file_exists($TR2) &&! file_exists($filtered))
			{
			system("nice 3dFourier -prefix " .$filtered ." -highpass 0.01 -lowpass 0.1 " .$TR2);
			}	

		//Mask filtered data
		$mask = $inputDir ."/rs_830_mean_mc_n3_mask.nii.gz";
		
		if(file_exists($filtered))
			{
			system("fslmaths " .$filtered ." -mas " .$mask ." " .$filtered);
			}			
	
		}	
	}

?>

