#!/usr/bin/php
<?php
	$dataDir = "";
	$processedDir = "";

	$rats = array(2,3,4,5,7,8,9,10,11,12,13,14,15,16,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,41);
	$times = array(1,10);
	
	foreach ($rats as $rat)
	{
		foreach ($times as $time)	
		{
		print "We are processing rat " .$rat ." restingstate " .$time ."\n";

		//Calculate FC matrix; input is filtered rs data; use file with all ROIs in individual rs space (after registrations!)
		$inputmatrix = $dataDir ."/rs_830_filtered_and_motion_parameters_regressed.nii.gz"; 
		$outputmatrix = $processedDir ."/z_score_fc_matrix.nii.gz";
		$roi = $dataDir ."/ROIs_in_individual_rs_space.nii.gz"; 

		//Use Fisher's Z transformed correlation coefficient if you want to calculate averages across individual rats (-a 6)
		//lr gives the range of intensity values of ROIs (In this case 2 ROIs, to 1 2)
		if(file_exists($inputmatrix) && file_exists($roi))
			{
			system("fcm -i $inputmatrix -o $outputmatrix -x TRUE -l $roi -a 6 --lr 1 2");
			}


		//Transform .nii.gz matrix to .csv matrix for further processing in R
		$matrixin = $outputmatrix;
		$matrixcsv = $processedDir ."/z_score_fc_matrix.csv";

		if(file_exists($matrixin))
			{
			system("matrix2csv -i $matrixin -o $matrixcsv");
			}
		}
	}

?>
	
