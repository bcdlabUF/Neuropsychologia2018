# Neuropsychologia2018

All of the scripts used in Barry-Anwar et al 2018.

Data was recorded in Netstation. All analyses were carried out in Matlab/eeglab.

1. Step1: ELFI_dataprocessing_Conditions_Final.m filters the data and segments based on the type of trial. (PreMacaque.txt and PreCapuchin.txt are bin files for segmenting here). This script requires data to be saved as .set and .fdt files.

2. Step2: check_data_EFLI.m removes the outer band of electrodes (due to excessive noise in our dataset). Because these electrodes have been removed, we created a new electrode location file to reflect this (locsEEGLAB109HCL.mat). Then the channels are cleaned and an average reference is computed. 

  2a. Files needed: locsEEGLAB109HCL.mat; avg_ref3d_baby109_noOuter.m
