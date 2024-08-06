#!/bin/env bash
#SBATCH --job-name=MRIQC_individual
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=8000
#SBATCH --qos=normal
#SBATCH -A kg98
#SBATCH --array=1-39
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90

# NOTE: this dataset needs to be BIDS formatted AND your sublist text file should have the sub- prefix omitted (e.g., sub-0001 should just be 0001)
SUBJECT_LIST="/path/to/sublist.txt"

#SLURM_ARRAY_TASK_ID=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

#set paths
BIDS_DIR=/path/to/BIDS_DIR
OUT_DIR=${BIDS_DIR}/derivatives/MRIQC
WORK_DIR=${OUT_DIR}/work

if [ ! -d $OUT_DIR ]; then mkdir -d $OUT_DIR; echo "making output directory"; fi
if [ ! -d $WORK_DIR ]; then mkdir $WORK_DIR; echo "making work directory"; fi

#load MRIQC
module purge
module load mriqc/0.15.2.rc1

#run MRIQC for single subject analysis

mriqc -v $BIDS_DIR $OUT_DIR participant \
--participant_label $subject \
--n_procs 12 \
--n_cpus 6 \
--mem_gb 12 \
--hmc-fsl \
-m T1w \
--correct-slice-timing \
--work-dir $WORK_DIR

# --------------------------------------------------------------------------------------------------

echo -e "\t\t\t ----- DONE ----- "

