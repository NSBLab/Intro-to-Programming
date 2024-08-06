#!/bin/env bash
#SBATCH --job-name=MRIQC_group
#SBATCH --account=kg98
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=1-00:00:00
#SBATCH --mail-user=<your.email>@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --export=ALL
#SBATCH --qos=normal
#SBATCH -A kg98

#set paths
BIDS_DIR=/path/to/BIDS_DIR
OUT_DIR=${BIDS_DIR}/derivatives/MRIQC
WORK_DIR=${OUT_DIR}/work
GROUP_DIR=${OUT_DIR}/group

if [ ! -d $GROUP_DIR ]; then mkdir $GROUP_DIR; echo "making group directory"; fi

# Load MRIQC module
module purge
module load mriqc/0.15.2.rc1

# Run MRIQC group report
mriqc -v $BIDS_DIR $OUT_DIR group \

# Move group report to the group_output folder
mv $OUT_DIR/group_T1w.html $GROUP_DIR
mv $OUT_DIR/group_T1w.tsv $GROUP_DIR

 -----------------------------------------------------------------------------------------END------------------------------------------------------------------------------------------

