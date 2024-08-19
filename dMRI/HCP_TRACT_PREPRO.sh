#!/bin/env bash

#SBATCH --job-name=HCP_prepro
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -t 0-3:0:0
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-973%200
#SBATCH --account=kg98

## This scripts takes the minimally preprocessed HCP data and performs some further preprocessing to create parcellations

declare -i ID=$SLURM_ARRAY_TASK_ID
echo $SLURM_ARRAY_TASK_ID

if [ ! -z $1 ]; then 
	RESTART=$1
else
	RESTART=0
fi

## RESTART=1 will remove everything produced by this script
RESTART=0

## CLEANUP=1 will remove temporary files this script uses
CLEANUP=1

## Location of scripts called upon by this present script
HCPSCRIPTS="/scratch/kg98/m3earlyadoptercibf"

## List of HCP subjects
SUBJECT_LIST="${HCPSCRIPTS}/HCP_SUBJECTS.txt"
SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})

## Where the parent directory for the data should be
HCPPARENTDIR="/scratch/kg98/stuarto-HCP/Preprocessed"

## The directory to store the parcellations
WORKDIR="${HCPPARENTDIR}/${SUBJECTID}/T1w/parc"

## Specify the cortical parcellation/s you want to make. Note the DK altas (i.e., aparc parcellation) is specified seperate in the options below
#CORTICAL_PARC_LIST="custom200 custom500 random200 random500 HCPMMP1 Schaefer200_17net Schaefer400_17net Schaefer900_17net"
CORTICAL_PARC_LIST="random200 random500"

## Specify the subcortical parcellation/s you want to use
SUBCORTICAL_PARC="fslatlas20"

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

source ${HCPSCRIPTS}/hcp_prepro_freesurfer_setup.sh

## Unpack the HCP data
if [ ! -d "${HCPPARENTDIR}/${SUBJECTID}" ]; then
	unzip /scratch/hcp1200/${SUBJECTID}/preproc/${SUBJECTID}_3T_Structural_preproc.zip -d ${HCPPARENTDIR}
	unzip /scratch/hcp1200/${SUBJECTID}/preproc/${SUBJECTID}_3T_Structural_preproc_extended.zip -d ${HCPPARENTDIR}	
	unzip /scratch/hcp1200/${SUBJECTID}/preproc/${SUBJECTID}_3T_Diffusion_preproc.zip -d ${HCPPARENTDIR}
fi

if [ -d "${WORKDIR}" ]; then
if [ "${RESTART}" -eq 1 ]; then
	rm -Rv ${WORKDIR}
	mkdir -v ${WORKDIR}
	mrconvert ${HCPPARENTDIR}/${SUBJECTID}/T1w/ribbon.nii.gz ${WORKDIR}/ribbon_expanded.nii -stride -1,2,3
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/MNINonLinear/xfms/standard2acpc_dc.nii.gz ${WORKDIR}/standard2acpc_dc.nii.gz
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/MNINonLinear/xfms/acpc_dc2standard.nii.gz ${WORKDIR}/acpc_dc2standard.nii.gz
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/T1w/aparc+aseg.nii.gz ${WORKDIR}/aparc+aseg.nii.gz
else
	echo -e "${WORKDIR} already exists. Continuing."
fi
elif [ ! -d "${WORKDIR}" ]; then
	mkdir -v ${WORKDIR}
	mrconvert ${HCPPARENTDIR}/${SUBJECTID}/T1w/ribbon.nii.gz ${WORKDIR}/ribbon_expanded.nii -stride -1,2,3
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/MNINonLinear/xfms/standard2acpc_dc.nii.gz ${WORKDIR}/standard2acpc_dc.nii.gz
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/MNINonLinear/xfms/acpc_dc2standard.nii.gz ${WORKDIR}/acpc_dc2standard.nii.gz
	cp -Rfv ${HCPPARENTDIR}/${SUBJECTID}/T1w/aparc+aseg.nii.gz ${WORKDIR}/aparc+aseg.nii.gz
fi



#export CUSTOMDIR="/scratch/kg98/m3earlyadoptercibf/HCP_parc/custom";
#export FS_SUBJECTS_DIR="/scratch/kg98/m3earlyadoptercibf/HCP_parc";


if [ ${RUN_CUSTOM_PARC} = 1 ]; then

for CORTICAL_PARC in ${CORTICAL_PARC_LIST}; do

if [ ${CORTICAL_PARC} = 'HCPMMP1' ]; then

L_cort="1:180"
R_cort="181:360"
N_cortical_per_hemi="180"
N_subcortical_per_hemi="10"

elif [ ${CORTICAL_PARC} = 'custom200' ]; then

L_cort="1:100"
R_cort="101:200"
N_cortical_per_hemi="100"
N_subcortical_per_hemi="10"

elif [ ${CORTICAL_PARC} = 'custom500' ]; then

L_cort="1:250"
R_cort="251:500"
N_cortical_per_hemi="250"
N_subcortical_per_hemi="10"

elif [ ${CORTICAL_PARC} = 'random200' ]; then

L_cort="1:100"
R_cort="101:200"
N_cortical_per_hemi="100"
N_subcortical_per_hemi="10"
PARCS=200

elif [ ${CORTICAL_PARC} = 'random500' ]; then

L_cort="1:250"
R_cort="251:500"
N_cortical_per_hemi="250"
N_subcortical_per_hemi="10"
PARCS=500

elif [ ${CORTICAL_PARC} = 'Schaefer200_17net' ]; then

L_cort="1:100"
R_cort="101:200"
N_cortical_per_hemi="100"
N_subcortical_per_hemi="10"
PARCS=200

elif [ ${CORTICAL_PARC} = 'Schaefer400_17net' ]; then

L_cort="1:200"
R_cort="201:400"
N_cortical_per_hemi="400"
N_subcortical_per_hemi="10"
PARCS=400

elif [ ${CORTICAL_PARC} = 'Schaefer900_17net' ]; then

L_cort="1:450"
R_cort="451:900"
N_cortical_per_hemi="450"
N_subcortical_per_hemi="10"
PARCS=900

fi

## Map the parcellation from .annot files to the T1w volume

mri_surf2surf --srcsubject custom --hemi lh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID}/T1w/${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${HCPPARENTDIR}/${SUBJECTID}/T1w/${SUBJECTID}/label/lh.${CORTICAL_PARC}.annot

mri_surf2surf --srcsubject custom --hemi rh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID}/T1w/${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${HCPPARENTDIR}/${SUBJECTID}/T1w/${SUBJECTID}/label/rh.${CORTICAL_PARC}.annot

mri_aparc2aseg --s ${SUBJECTID}/T1w/${SUBJECTID} --o ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --new-ribbon --annot ${CORTICAL_PARC}

mri_label2vol --seg ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --temp ${HCPPARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_brain.nii.gz --o ${WORKDIR}/${CORTICAL_PARC}_label2vol.nii --regheader ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz

#mri_surf2surf --srcsubject custom --hemi lh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${WORKDIR}/label/lh.${CORTICAL_PARC}.annot

#mri_surf2surf --srcsubject custom --hemi rh --sval-annot ${CORTICAL_PARC}.annot --trgsubject ${SUBJECTID} --srcsurfreg sphere.reg --trgsurfreg sphere.reg --tval ${WORKDIR}/label/rh.${CORTICAL_PARC}.annot

#mri_aparc2aseg --s ${SUBJECTID} --o ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --new-ribbon --annot ${CORTICAL_PARC}

#mri_label2vol --seg ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz --temp ${WORKDIR}/T1w_acpc_dc_restore_brain.nii.gz --o ${WORKDIR}/${CORTICAL_PARC}_label2vol.nii --regheader ${WORKDIR}/${CORTICAL_PARC}+aseg.mgz

## Make the parcellation strides in the right format for FSL

mrconvert ${WORKDIR}/${CORTICAL_PARC}_label2vol.nii ${WORKDIR}/${CORTICAL_PARC}_uncorr.nii -stride -1,2,3

if [ ! -f "${WORKDIR}/${CORTICAL_PARC}_uncorr.nii" ]; then
	exit;
fi

## Relabel ROIs. Relabels ROIs so they are in increasing integers starting from 1

## Checks if the parcellation is the Schaefer or not. If so it runs a different script to relabel regions

if [ ${CORTICAL_PARC:0:8} = 'Schaefer' ]; then


INFILE="${WORKDIR}/${CORTICAL_PARC}_uncorr.nii"

OUTFILE="${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii";

## This script probably works on any parcellation provided you just tell it how many ROIs there are across the cortex. Haven't tested it though
matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); ConfigSchaeferParc('${INFILE}',${PARCS},'${OUTFILE}'); exit"

#matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); ConfigureParc('${INFILE}',${PARCS},'${OUTFILE}'); exit"

else

INFILE="${WORKDIR}/${CORTICAL_PARC}_uncorr.nii"

OUTFILE="${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii";

matlab -nodisplay -nosplash -r "WheresMyScript='${HCPSCRIPTS}/Functions'; addpath(genpath(WheresMyScript)); ConfigureParc('${INFILE}',${PARCS},'${OUTFILE}'); exit"

## Old script for relabelling ROIs

#WHERESMYSCRIPT="/projects/kg98/stuarto/M2/scratch/scratch_shared/GenCog/code"
#INFILE="${WORKDIR}/${CORTICAL_PARC}_uncorr.nii"
#LIST="${WHERESMYSCRIPT}/origvals_cort_${CORTICAL_PARC}.txt"
#OUTFILE="${WORKDIR}/${CORTICAL_PARC}_config_uncorr.nii"
#matlab -nodisplay -nosplash -r "addpath('${WHERESMYSCRIPT}'); ConfigParc('${INFILE}','${LIST}','${OUTFILE}'); exit"

#SEGNAME="${CORTICAL_PARC}";
#INFILE="${WORKDIR}/${CORTICAL_PARC}_config_uncorr.nii"
#OUTFILE="${WORKDIR}/${CORTICAL_PARC}_acpc_uncorr.nii";

#matlab -nodisplay -nosplash -r "addpath('${WHERESMYSCRIPT}'); RelabelRegions('${SEGNAME}','${INFILE}','${OUTFILE}'); exit" 

fi

## Relabel hippocampus in the HCPMMP1 parcellation

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

applywarp --ref=${HCPPARENTDIR}/${SUBJECTID}/T1w/T1w_acpc_dc_restore_brain.nii.gz --in=/projects/kg98/stuarto/M2/scratch/scratch_shared/GenCog/subjects/standard/striatum6ANDthalamus14_config.nii --warp=${WORKDIR}/standard2acpc_dc.nii.gz --out=${WORKDIR}/${SUBCORTICAL_PARC}_unordered.nii --interp=nn

matlab -nodisplay -nosplash -r "addpath('${HCPSCRIPTS}'); addpath('${HCPSCRIPTS}/Functions'); Relabel_fslatlas20('${WORKDIR}/${SUBCORTICAL_PARC}_unordered.nii','${WORKDIR}/${SUBCORTICAL_PARC}_acpc.nii'); exit"

fi

## Combine the cortical and subcortical parcellation

if [ ${COMBINE_CORT_AND_SUB} = 1 ]; then 

for CORTICAL_PARC in ${CORTICAL_PARC_LIST}; do

matlab -nodisplay -nosplash -r "addpath('${HCPSCRIPTS}'); addpath('${HCPSCRIPTS}/Functions'); combine_cort_subcort('${WORKDIR}/${CORTICAL_PARC}_acpc.nii','${WORKDIR}/${SUBCORTICAL_PARC}_acpc.nii','${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_acpc.nii'); exit"

applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_acpc.nii --warp=${WORKDIR}/acpc_dc2standard.nii.gz --out=${WORKDIR}/${CORTICAL_PARC}AND${SUBCORTICAL_PARC}_standard.nii --interp=nn

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




