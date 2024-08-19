#!/bin/env bash

#SBATCH --job-name=HCP_prepro
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -t 1-0:0:0
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=4G
#SBATCH --account=kg98
#SBATCH --output=/fs04/kg98/stuarto/HCP_parc/SLURM_OUTPUT/prepro-%j.out
#SBATCH --array=1-10%10


##SBATCH --array=1-973%200

## This scripts takes the minimally preprocessed HCP data and performs some further preprocessing to create parcellations

#ID=$1
declare -i ID=$SLURM_ARRAY_TASK_ID
echo $SLURM_ARRAY_TASK_ID

## RESTART=1 will remove everything produced by this script
RESTART=0

## CLEANUP=1 will remove temporary files this script uses
CLEANUP=1

## Location of scripts called upon by this present script
#HCPSCRIPTS="/scratch/kg98/m3earlyadoptercibf"
HCPSCRIPTS="/fs04/kg98/stuarto/HCP_parc"

## List of HCP subjects
#SUBJECT_LIST="${HCPSCRIPTS}/HCP_SUBJECTS.txt"
SUBJECT_LIST="${HCPSCRIPTS}/missingSubjects.txt"
SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})

## Where the parent directory for the data should be
HCPPARENTDIR="/fs04/kg98/stuarto/HCP_parc/SUBJECTS"

## T1w image location
T1w_path="${HCPPARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_brain.nii.gz"

## The directory to store the parcellations
WORKDIR="${HCPPARENTDIR}/${SUBJECTID}/parc"

## Specify the cortical parcellation/s you want to make. Note if you make a new parcellation you need to define the values that make up the left hemisphere, the right hemisphere, and the total number of rois/parcels as well (see below)
#CORTICAL_PARC_LIST="HCPMMP1 random200 random500 Schaefer100_7net Schaefer200_7net Schaefer300_7net Schaefer400_7net Schaefer500_7net Schaefer600_7net Schaefer800_7net Schaefer900_7net Schaefer1000_7net Schaefer100_17net Schaefer200_17net Schaefer300_17net Schaefer400_17net Schaefer500_17net Schaefer600_17net Schaefer800_17net Schaefer900_17net Schaefer1000_17net"

CORTICAL_PARC_LIST="Schaefer100_7net Schaefer200_7net Schaefer300_7net Schaefer400_7net Schaefer500_7net Schaefer600_7net Schaefer700_7net Schaefer800_7net Schaefer900_7net Schaefer1000_7net Schaefer100_17net Schaefer200_17net Schaefer300_17net Schaefer400_17net Schaefer500_17net Schaefer600_17net Schaefer700_17net Schaefer800_17net Schaefer900_17net Schaefer1000_17net"

#CORTICAL_PARC_LIST="Schaefer700_7net Schaefer700_17net"

#CORTICAL_PARC_LIST="Schaefer200_7net Schaefer400_7net"
## Specify the subcortical parcellation/s you want to use
#SUBCORTICAL_PARC_LIST="TianS2 fslatlas"
SUBCORTICAL_PARC_LIST="TianS2"
#SUBCORTICAL_PARC="fslatlas20"

## Use the Freesurfer subcortical segmentation to make a parcellation 
RUN_FREESURFER_PARC=0

## Run the code to generate a new parcellation
RUN_CUSTOM_PARC=1

## Create subcortical parcellations
RUN_SUBCORTICAL_PARC=1

## Replaces the subcortical ROIs from Freesurfer with those produced by FIRST
RUN_SGM_FIX=1

## Combines the cortical and suncortical parcelations (will also provide seperate images as well)
COMBINE_CORT_AND_SUB=1

module load fsl/5.0.9
module load matlab
module load mrtrix/0.3.16
module unload gcc/4.9.3
module load gcc/5.4.0
module load freesurfer/5.3

source /projects/kg98/stuarto/HCP_parc/hcp_prepro_freesurfer_setup.sh

if [ ${RUN_CUSTOM_PARC} = 1 ]; then

for CORTICAL_PARC in ${CORTICAL_PARC_LIST}; do

# Define the values that make up the left hemisphere, the right hemisphere, and the total number of rois/parcels here
if [ ${CORTICAL_PARC} = 'HCPMMP1' ]; then

L_cort="1:180"
R_cort="181:360"
PARCS=360

elif [ ${CORTICAL_PARC} = 'random200' ]; then

L_cort="1:100"
R_cort="101:200"
PARCS=200

elif [ ${CORTICAL_PARC} = 'random500' ]; then

L_cort="1:250"
R_cort="251:500"
PARCS=500

elif [ ${CORTICAL_PARC} = "Schaefer100_17net" ]; then
L_cort="1:50"
R_cort="51:100"
PARCS=100
elif [ ${CORTICAL_PARC} = "Schaefer200_17net" ]; then
L_cort="1:100"
R_cort="101:200"
PARCS=200
elif [ ${CORTICAL_PARC} = "Schaefer300_17net" ]; then
L_cort="1:150"
R_cort="151:300"
PARCS=300
elif [ ${CORTICAL_PARC} = "Schaefer400_17net" ]; then
L_cort="1:200"
R_cort="201:400"
PARCS=400
elif [ ${CORTICAL_PARC} = "Schaefer500_17net" ]; then
L_cort="1:250"
R_cort="251:500"
PARCS=500
elif [ ${CORTICAL_PARC} = "Schaefer600_17net" ]; then
L_cort="1:300"
R_cort="301:600"
PARCS=600
elif [ ${CORTICAL_PARC} = "Schaefer700_17net" ]; then
L_cort="1:350"
R_cort="351:700"
PARCS=700
elif [ ${CORTICAL_PARC} = "Schaefer800_17net" ]; then
L_cort="1:400"
R_cort="401:800"
PARCS=800
elif [ ${CORTICAL_PARC} = "Schaefer900_17net" ]; then
L_cort="1:450"
R_cort="451:900"
PARCS=900
elif [ ${CORTICAL_PARC} = "Schaefer1000_17net" ]; then
L_cort="1:500"
R_cort="501:1000"
PARCS=1000
elif [ ${CORTICAL_PARC} = "Schaefer100_7net" ]; then
L_cort="1:50"
R_cort="51:100"
PARCS=100
elif [ ${CORTICAL_PARC} = "Schaefer200_7net" ]; then
L_cort="1:100"
R_cort="101:200"
PARCS=200
elif [ ${CORTICAL_PARC} = "Schaefer300_7net" ]; then
L_cort="1:150"
R_cort="151:300"
PARCS=300
elif [ ${CORTICAL_PARC} = "Schaefer400_7net" ]; then
L_cort="1:200"
R_cort="201:400"
PARCS=400
elif [ ${CORTICAL_PARC} = "Schaefer500_7net" ]; then
L_cort="1:250"
R_cort="251:500"
PARCS=500
elif [ ${CORTICAL_PARC} = "Schaefer600_7net" ]; then
L_cort="1:300"
R_cort="301:600"
PARCS=600
elif [ ${CORTICAL_PARC} = "Schaefer700_7net" ]; then
L_cort="1:350"
R_cort="351:700"
PARCS=700
elif [ ${CORTICAL_PARC} = "Schaefer800_7net" ]; then
L_cort="1:400"
R_cort="401:800"
PARCS=800
elif [ ${CORTICAL_PARC} = "Schaefer900_7net" ]; then
L_cort="1:450"
R_cort="451:900"
PARCS=900
elif [ ${CORTICAL_PARC} = "Schaefer1000_7net" ]; then
L_cort="1:500"
R_cort="501:1000"
PARCS=1000

fi

## Map the parcellation from .annot files to the T1w volume

mri_surf2surf --srcsubject custom --hemi lh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${HCPPARENTDIR}/${SUBJECTID}/label/lh.${CORTICAL_PARC}.annot

mri_surf2surf --srcsubject custom --hemi rh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${HCPPARENTDIR}/${SUBJECTID}/label/rh.${CORTICAL_PARC}.annot

mri_aparc2aseg --s ${SUBJECTID} --o ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --new-ribbon --annot ${CORTICAL_PARC}

mri_label2vol --seg ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --temp ${HCPPARENTDIR}/${SUBJECTID}/T1w_acpc_dc_restore_brain.nii.gz --o ${WORKDIR}/${CORTICAL_PARC}_label2vol.nii --regheader ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz

## Make the parcellation strides in the right format for FSL

mrconvert ${WORKDIR}/${CORTICAL_PARC}_label2vol.nii ${WORKDIR}/${CORTICAL_PARC}_uncorr.nii -stride -1,2,3

if [ ! -f "${WORKDIR}/${CORTICAL_PARC}_uncorr.nii" ]; then
	exit;
fi

## Relabel ROIs. Relabels ROIs so they are in increasing integers starting from 1

## Checks if the parcellation is the Schaefer or not. If so it runs a different script to relabel regions

INFILE="${WORKDIR}/${CORTICAL_PARC}_uncorr.nii"

OUTFILE="${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii";

INFILE="${WORKDIR}/${CORTICAL_PARC}_uncorr.nii"

OUTFILE="${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii";

matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); ConfigureParc('${INFILE}',${PARCS},'${OUTFILE}'); exit"

## Relabel hippocampus in the HCPMMP1 parcellation as it is badly definied using just the cortical labels

if [ ${CORTICAL_PARC} = 'HCPMMP1' ]; then

export FSLSUB_LOCAL_RUN=YES


	## The HCPMMP1 parcellation includes the hippocampus but it does not show up especially well in this parcellation. Therefore we run FIRST to get the hippocampus and use that ROI instead

	cp -rf ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_poor_hipp.nii
	rm -v ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii
	
	rm -rfv ${WORKDIR}/FIRST
	mkdir ${WORKDIR}/FIRST

	fslmaths ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_poor_hipp.nii -thr 120 -uthr 120 -bin -mul 300 -add ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_poor_hipp.nii -thr 300 -uthr 300 -bin -add 1 -sub 2 -abs -mul ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_poor_hipp.nii ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_no_hipp.nii

	run_first_all -s L_Hipp,R_Hipp -i ${HCPPARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_brain.nii.gz -o ${WORKDIR}/FIRST/first -b

	fslmaths ${WORKDIR}/FIRST/first_all_fast_firstseg.nii -thr 17 -uthr 17 -bin -mul 120 ${WORKDIR}/L_Hipp.nii
	fslmaths ${WORKDIR}/FIRST/first_all_fast_firstseg.nii -thr 53 -uthr 53 -bin -mul 300 ${WORKDIR}/R_Hipp.nii

	## Binarise the hippocampus masks, add 1 then subtract 2 and then get the absolute values to created an inverted mask. Multiply the parcellation by the inverted image to 
	## remove any voxels they were labelled in the hippocampus and then add on the masks 

	fslmaths ${WORKDIR}/L_Hipp.nii -add ${WORKDIR}/R_Hipp.nii -bin -add 1 -sub 2 -abs -mul ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr_no_hipp.nii -add ${WORKDIR}/L_Hipp.nii -add ${WORKDIR}/R_Hipp.nii ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii

fi

## Correct for mislabelled ROIs. Some areas along the midline and labelled as right when they should be left and vice-verse. This script just finds those bad ROIs (based on the division into left and right by the cortical ribbon from Freesurfer) and relabels them based on the proximety to ROIs in its own hemisphere

matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); Parc_correct_mislabel('${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii','${WORKDIR}/ribbon_expanded.nii',${L_cort},${R_cort},'${WORKDIR}/${CORTICAL_PARC}_acpc.nii'); exit"

## Put the cortical parcellation into MNI space

applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/${CORTICAL_PARC}_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/${CORTICAL_PARC}_standard.nii --interp=nn

## Remove files you won't need

if [ ${CLEANUP} = 1 ]; then
	rm -Rfv ${WORKDIR}/${CORTICAL_PARC}_uncorr.nii
	rm -Rfv ${WORKDIR}/${CORTICAL_PARC}_config_uncorr.nii
	rm -Rfv ${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii
fi

done

fi

## Generate the subcortical parcellation

if [ ${RUN_SUBCORTICAL_PARC} = 1 ]; then 

for SUBCORTICAL_PARC in ${SUBCORTICAL_PARC_LIST}; do

if [ ${SUBCORTICAL_PARC} = 'fslatlas20' ]; then

applywarp --ref=${HCPPARENTDIR}/${SUBJECTID}/T1w_acpc_dc_restore_brain.nii.gz --in=/projects/kg98/stuarto/M2/scratch/scratch_shared/GenCog/subjects/standard/striatum6ANDthalamus14_config.nii --warp=${WORKDIR}/standard2acpc_dc.nii.gz --out=${WORKDIR}/${SUBCORTICAL_PARC}_unordered.nii --interp=nn

elif [ ${SUBCORTICAL_PARC} = 'TianS2' ]; then

applywarp --ref=${HCPPARENTDIR}/${SUBJECTID}/T1w_acpc_dc_restore_brain.nii.gz --in=/projects/kg98/stuarto/HCP_parc/TianS2.nii.gz --warp=${WORKDIR}/standard2acpc_dc.nii.gz --out=${WORKDIR}/${SUBCORTICAL_PARC}_unordered.nii --interp=nn

fi

matlab -nodisplay -nosplash -r "addpath('${HCPSCRIPTS}'); addpath('${HCPSCRIPTS}/Functions'); Relabel_${SUBCORTICAL_PARC}('${WORKDIR}/${SUBCORTICAL_PARC}_unordered.nii','${WORKDIR}/${SUBCORTICAL_PARC}_acpc.nii'); exit"

done

fi

## Combine the cortical and subcortical parcellation

if [ ${COMBINE_CORT_AND_SUB} = 1 ]; then 

for CORTICAL_PARC in ${CORTICAL_PARC_LIST}; do

for SUBCORTICAL_PARC in ${SUBCORTICAL_PARC_LIST}; do

matlab -nodisplay -nosplash -r "addpath('${HCPSCRIPTS}'); addpath('${HCPSCRIPTS}/Functions'); combine_cort_subcort('${WORKDIR}/${CORTICAL_PARC}_acpc.nii','${WORKDIR}/${SUBCORTICAL_PARC}_acpc.nii','${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_acpc.nii'); exit"

applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_standard.nii --interp=nn

done

done

fi

## Make the Freesurfer parcellation

if [ ${RUN_FREESURFER_PARC} = 1 ]; then

## Replaces the subcortical ROIs with those produced by FIRST

labelconvert -force ${WORKDIR}/aparc+aseg.nii.gz ${HCPSCRIPTS}/Nodes/FreeSurferLUTs/FreeSurferColorLUT.txt ${HCPSCRIPTS}/Nodes/fs_custom.txt ${WORKDIR}/aparc+aseg_uncorr.mif
mrconvert -force -quiet ${WORKDIR}/aparc+aseg_uncorr.mif ${WORKDIR}/aparc+aseg_uncorr.nii -stride -1,2,3

	if [ ${RUN_SGM_FIX} = 1 ]; then

	export FSLSUB_LOCAL_RUN=YES

	labelsgmfix -tempdir ${WORKDIR} -force ${WORKDIR}/aparc+aseg_uncorr.mif ${HCPPARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_brain.nii.gz ${HCPSCRIPTS}/Nodes/fs_custom.txt ${WORKDIR}/aparc+first_uncorr.mif -premasked
	mrconvert -force -quiet ${WORKDIR}/aparc+first_uncorr.mif ${WORKDIR}/aparc+first_uncorr.nii -stride -1,2,3

	matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); Parc_correct_mislabel('${WORKDIR}/aparc+first_uncorr.nii','${WORKDIR}/ribbon_expanded.nii',1:34,42:75,'${WORKDIR}/aparc+first_acpc.nii',[35:41 76:82]); exit"

	applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/aparc+first_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/aparc+first_standard.nii --interp=nn


	if [ ${CLEANUP} = 1 ]; then
		rm -Rfv ${WORKDIR}/aparc+first_uncorr.mif
		rm -Rfv ${WORKDIR}/aparc+first_uncorr.nii
	fi

	fi

matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); Parc_correct_mislabel('${WORKDIR}/aparc+aseg_uncorr.nii','${WORKDIR}/ribbon_expanded.nii',1:34,42:75,'${WORKDIR}/aparc+aseg_acpc.nii',[35:41 76:82]); exit"

applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/aparc+aseg_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/aparc+aseg_standard.nii --interp=nn

matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); extract_ROIs('${WORKDIR}/aparc+aseg_acpc.nii',[1:34 42:75],'${WORKDIR}/aparc_acpc.nii',1); exit"

applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/aparc_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/aparc_standard.nii --interp=nn

if [ ${CLEANUP} = 1 ]; then
	rm -Rfv ${WORKDIR}/aparc+aseg_uncorr.mif
	rm -Rfv ${WORKDIR}/aparc+aseg_uncorr.nii
	rm -Rfv ${WORKDIR}/aparc+aseg.nii.gz
fi


fi
