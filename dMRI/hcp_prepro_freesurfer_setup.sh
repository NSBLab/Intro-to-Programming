#!/bin/bash
export FILESEP="/"
export WHERESMYSCRIPT="/projects/kg98/stuarto/HCP_parc"
export WHEREERRORLOG="/projects/kg98/stuarto/HCP_parc/ErrorLog_after_edit"
export PARENTDIR="/projects/kg98/stuarto/HCP_parc/SUBJECTS"
export T1WDIRNAME="T1w"
export DWDIRNAME="diffusion"
export MNILINEARDIRNAME="MNILinear"
export FIRSTDIRNAME="first"
export FS_SUBJECTS_DIR="/projects/kg98/stuarto/HCP_parc/SUBJECTS"
export FREESURFERDIR="/usr/local/freesurfer/5.3"
export FSLDIR="/usr/local/fsl/5.0.9" # export FSLDIR="/usr/local/fsl/5.0.8"
module load freesurfer/5.3
module load fsl/5.0.9 # module load fsl/5.0.8
module load connectome/1.2.3 # module load connectome/1.0
module unload gcc/4.9.3
module load gcc/5.4.0
export FREESURFER_HOME="${FREESURFERDIR}"
export FSFAST_HOME="${FREESURFERDIR}${FILESEP}fsfast"
export FSF_OUTPUT_FORMAT="nii"
export SUBJECTS_DIR="${FS_SUBJECTS_DIR}"
export FUNCTIONALS_DIR="${FREESURFERDIR}${FILESEP}sessions"
export MNI_DIR="${FREESURFERDIR}${FILESEP}mni"
export FSL_DIR="${FSLDIR}"
source ${WHERESMYSCRIPT}${FILESEP}FreeSurferEnv.sh
export FSLOUTPUTTYPE="NIFTI"
module list
export CUSTOMDIR="/projects/kg98/stuarto/HCP_parc/SUBJECTS/custom"
export STANDARDDIR="${SUBJECTS_DIR}${FILESEP}standard"
CHECKS="${CUSTOMDIR} ${STANDARDDIR}"
for CHECK in ${CHECKS}; do
    if [ ! -e "${CHECK}" ]; then
        echo -e ${COL_RED}"Warning. "${COL_RESET}"No such directory: ${CHECK}"
    fi
    unset CHECK
done
unset CHECKS
