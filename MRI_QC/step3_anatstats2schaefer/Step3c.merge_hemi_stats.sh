#!/bin/env bash

#SBATCH --job-name=Step3_merge_hemi
#SBATCH --cpus-per-task=1
#SBATCH --mail-user=<>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --mem-per-cpu=4G
#SBATCH --time 4:00:00

OUTDIR=/path/to/output/derivatives/directory # add path to output directory (probably something like /bids_root/derivatives/anat_stats idk)

# also add sublist path
for subject in `cat /path/to/fs_sublist.txt` ; do
for p in 100 200 300 400 500 600 700 800 900 1000 ; do
  head -n 1 ${OUTDIR}/${p}/tmp/${subject}_lh.Schaefer2018_${p}Parcels_7Networks_order.txt > ${OUTDIR}/${p}/${subject}.Schaefer2018_${p}Parcels_7Networks_order.txt; tail -n +2 -q ${OUTDIR}/${p}/tmp/${subject}_?h.Schaefer2018_${p}Parcels_7Networks_order.txt >> ${OUTDIR}/${p}/${subject}.Schaefer2018_${p}Parcels_7Networks_order.txt ;
 done ; done

# I haven't really added any cleanup to these scripts, so you might want to delete the ${OUTDIR}/${p}/tmp directories. You can add that here with rm -r ${OUTDIR}/${p}/tmp etc etc

