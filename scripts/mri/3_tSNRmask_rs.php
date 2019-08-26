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
		print "We are calculating the tSNRmask for  rat " .$rat ." restingstate " .$time ."\n";
		$indir = $dataDir ."/rat-" .$rat ."-time-" .$time;
		$outdir = $processedDir ."/rat-". $rat ."-time-" .$time;
	
		#Calculate standard devation over time
		$input = $indir ."/rs_830_mc.nii.gz";
		$output = $outdir ."/rs_830_mc_tstd.nii.gz";
		if(file_exists($input) &&! file_exists($output))
			{
			system("fslmaths " .$input ." -Tstd " .$output);
			}

		#Calculate tSNR by mean/Tstd
		$input = $indir ."/rs_830_mean_mc_mean.nii.gz";
		$output = $outdir ."/rs_830_mc_tSNR.nii.gz";
		$tstd = $indir ."/rs_830_mc_tstd.nii.gz";
		if(file_exists($input) && file_exists($tstd) &&! file_exists($output))
			{
			system("fslmaths " .$input ." -div " .$tstd ." " .$output);
			}

		#mask tSNR
		$input = $indir ."/rs_830_mc_tSNR.nii.gz";
		$mask = $indir ."/rs_830_mean_mc_n3_mask.nii.gz";
		$output = $outdir ."/rs_830_mc_tSNR_masked.nii.gz";
		if(file_exists($input) && file_exists($mask) &&! file_exists($output))
			{
			system("fslmaths " .$input ." -mas " .$mask ." " .$output);
			}

		#Make tSNR10 by thresholding at 10 and binarizing
		$input = $indir ."/rs_830_mc_tSNR_masked.nii.gz";
		$output = $indir ."/rs_8_mc_tSNR10_masked.nii.gz";
		if(file_exists($input) &&! file_exists($output))
			{
			system("fslmaths " .$input ." -thr 10 -bin " .$output);
			}
		}
	}

?>
