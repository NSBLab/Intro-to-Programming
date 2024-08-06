#!/bin/env bash

#SBATCH --job-name=Step1_fs2schaefer
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time 4:00:00
#SBATCH --mail-user=<>@monash.edu 
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --mem-per-cpu=4G
#SBATCH --qos=normal
#SBATCH -A kg98
#SBATCH --array=1-800

# change sbatch array to number of subjects (e.g., 1-100 or 1-250, etc)
# also change email

SUBJECT_LIST="/path/to/fs_sublist.txt" # sublist txt file (sub id should match freesurfer directory names)

#SLURM_ARRAY_TASK_ID=1
subject=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"


module purge
module load freesurfer/7.1.0
export SUBJECTS_DIR=/path/to/freesurfer/subjects # add path to freesurfer subjects dir

for p in 100 200 300 400 500 600 700 800 900 1000 ; do
for h in lh rh ; do

  mris_ca_label -l $SUBJECTS_DIR/${subject}/label/${h}.cortex.label \
  ${subject} ${h} $SUBJECTS_DIR/${subject}/surf/${h}.sphere.reg \
  /projects/kg98/aholmes/freesurfer_holmesQC/step3_anatstats2schaefer/gcs/${h}.Schaefer2018_${p}Parcels_7Networks.gcs \
  $SUBJECTS_DIR/${subject}/label/${h}.Schaefer2018_${p}Parcels_7Networks_order.annot ;
  done ; done


