#!/bin/env bash
#SBATCH --job-name=SchafConns
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH -t 2-0:0:0
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=6G
#SBATCH --account=kg98
#SBATCH --array=1-973%200

#declare -i ID=$SLURM_ARRAY_TASK_ID
ID=$1

module load mrtrix/0.3.15-gcc4
module load fsl/5.0.9
module load python/2.7.12-gcc4
module load matlab/r2016a

WHERESMYSCRIPT="/projects/kg98/stuarto/HCP_parc"
SUBJECT_LIST="${WHERESMYSCRIPT}/GENMDL_SUBJECTS.txt"

#PREPROCESSEDDIR="/scratch/kg98/stuarto-HCP/Preprocessed"
PROCESSEDDIR="/projects/hcp1200_processed/2021/Processed"

SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})
WORKDIR="${PROCESSEDDIR}/${SUBJECTID}"

echo ${SUBJECTID}
echo ${WORKDIR}

Connectome_Out="/projects/kg98/stuarto/HCP_parc/GenMdl_streamline_dist"

#for PARC_NAME in Schaefer1000_7netANDTianS2_acpc; do
#for PARC_NAME in Schaefer200_7net_acpc; do
for ALGOR_TYPE in FACT; do

tckstats -dump ${Connectome_Out}/${SUBJECTID}_${ALGOR_TYPE}_streamline_length.txt ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck

for PARC_NAME in random200ANDfslatlas20_acpc Schaefer200_7net_acpc Schaefer400_7net_acpc; do

CONN_PARC="/projects/kg98/stuarto/HCP_parc/SUBJECTS/${SUBJECTID}/parc/${PARC_NAME}.nii"

#for SIFT_TYPE in SIFT2 NOSIFT; do

for SIFT_TYPE in NOSIFT; do
#for ALGOR_TYPE in FACT iFOD2; do

if [ "${SIFT_TYPE}" = "SIFT2" ]; then
	SIFT_COMMAND="-tck_weights_in ${WORKDIR}/SIFT2_weights_${ALGOR_TYPE}.txt" 
else
	SIFT_COMMAND=""
fi

tck2connectome -force -out_assignments ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}_streamline_node_assign.txt -zero_diagonal -assignment_radial_search 5 ${SIFT_COMMAND} ${WORKDIR}/streamlines_${ALGOR_TYPE}.tck ${CONN_PARC} ${Connectome_Out}/${SUBJECTID}_${PARC_NAME}_${SIFT_TYPE}_${ALGOR_TYPE}.csv

date


date


done

done

done
