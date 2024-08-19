#!/bin/env bash
#SBATCH --job-name=SchafConns
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -t 2-0:0:0
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=6G
#SBATCH --account=kg98

ID=$1

module load mrtrix/0.3.15-gcc4
module load fsl/5.0.9
module load python/2.7.12-gcc4
module load matlab/r2016a

WHERESMYSCRIPT="/scratch/kg98/m3earlyadoptercibf"
SUBJECT_LIST="${WHERESMYSCRIPT}/HCP_SUBJECTS.txt"

#PREPROCESSEDDIR="/scratch/kg98/stuarto-HCP/Preprocessed"
PROCESSEDDIR="/projects/hcp1200_processed/2021/Processed"

SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})
WORKDIR="${PROCESSEDDIR}/${SUBJECTID}"

echo ${SUBJECTID}
echo ${WORKDIR}

Connectome_Out="/projects/kg98/stuarto/HCP_parc/SUBJECTS/${SUBJECTID}"

#for PARC_NAME in Schaefer1000_7netANDTianS2_acpc; do
#for PARC_NAME in Schaefer200_7net_acpc; do
for PARC_NAME in Schaefer200_7net_acpc Schaefer400_7net_acpc; do

CONN_PARC="/projects/kg98/stuarto/HCP_parc/SUBJECTS/${SUBJECTID}/parc/${PARC_NAME}.nii"

#for SIFT_TYPE in SIFT2 NOSIFT; do
for SIFT_TYPE in NOSIFT; do
for ALGOR_TYPE in FACT; do
#for ALGOR_TYPE in FACT iFOD2; do

if [ "${SIFT_TYPE}" = "SIFT2" ]; then
	SIFT_COMMAND="-tck_weights_in ${WORKDIR}/SIFT2_weights_${ALGOR_TYPE}.txt" 
else
	SIFT_COMMAND=""
fi

tck2connectome -force -zero_diagonal -assignment_radial_search 5 ${SIFT_COMMAND} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv

date

echo -e "\nMaking ${ALGOR_TYPE} ${PARC_NAME} connectome for lengths\n"
tck2connectome -force -zero_diagonal -scale_length -stat_edge mean -assignment_radial_search 5 ${SIFT_COMMAND} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.csv

date

echo -e "\nMaking ${ALGOR_TYPE} ${PARC_NAME} FA connectome\n"


tck2connectome -force -zero_diagonal -scale_file ${WORKDIR}/fa_mean.csv -stat_edge mean -assignment_radial_search 5 ${SIFT_COMMAND} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_FA.csv


#matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv','${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.mat'); exit"

#matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.csv','${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_length.mat'); exit"

#matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); csv_to_mat('${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_FA.csv','${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_FA.mat'); exit"

done

done

VOXDIM=($(mrinfo -vox ${CONN_PARC}))
echo -e "\n***FINDING ${PARC_NAME} NODE COORDINATES**\n"
matlab -nodisplay -nosplash -r "WheresMyScript='${WHERESMYSCRIPT}/Functions'; addpath(genpath(WheresMyScript)); getCOG('${CONN_PARC}',${VOXDIM},1,'/projects/kg98/stuarto/HCP_parc/SUBJECTS/${SUBJECTID}/COG_${PARC_NAME}_${SUBJECTID}.txt',1); exit"

done
