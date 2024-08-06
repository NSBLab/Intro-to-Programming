#!/bin/env bash

#SBATCH --job-name=Step2_schaeferCT
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
OUTDIR=/path/to/output/derivatives/directory # add path to output directory (probably something like /bids_root/derivatives/cortical_thickness idk)

for p in 100 200 300 400 500 600 700 800 900 1000 ; do
  mkdir ${OUTDIR}/${p}
  mkdir ${OUTDIR}/${p}/tmp
for h in lh rh ; do
  mris_anatomical_stats -a ${SUBJECTS_DIR}/${subject}/label/${h}.Schaefer2018_${p}Parcels_7Networks_order.annot -f ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt ${subject} ${h}
  sed -i 's/^.*StructName/StructName/' ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt
  sed -i '0,/^.*StructName/d' ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt
  sed -i -n '/StructName/,$p' ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt
  sed -i 's/ /,/g' ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt
  sed -i -e ':loop' -e 's/,,/,/g' -e 't loop' ${OUTDIR}/${p}/tmp/${subject}_${h}.Schaefer2018_${p}Parcels_7Networks_order.txt ;
  done ; done


