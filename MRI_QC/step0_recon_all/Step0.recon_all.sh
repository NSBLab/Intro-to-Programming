#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=recon-all
#SBATCH --mem-per-cpu=4G
#SBATCH --cpus-per-task=1
#SBATCH --time 30:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --array=1-39
#IMPORTANT! set the array range above to exactly the number of people in your SubjectIDs.txt file. e.g., if you have 90 subjects then array should be: --array=1-90

SUBJECT_LIST="/path/to/sublist.txt"

#SLURM_ARRAY_TASK_ID=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

module purge
module load freesurfer/7.1.0

BIDS_DIR=/path/to/dataset
export SUBJECTS_DIR=${BIDS_DIR}/derivatives/freesurfer
if [ ! -d $SUBJECTS_DIR ]; then mkdir -d $SUBJECTS_DIR; echo "making output directory"; fi
cd $SUBJECTS_DIR

recon-all -i ${BIDS_DIR}/${subject}/anat/${subject}_T1w.nii.gz -s ${subject} -all -qcache

echo ${subject}
