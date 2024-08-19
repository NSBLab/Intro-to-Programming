#!/bin/env bash

ID=$1

HCPSCRIPTS="/scratch/kg98/m3earlyadoptercibf"

SUBJECT_LIST="${HCPSCRIPTS}/HCP_SUBJECTS.txt"
SUBJECTID=$(sed -n "${ID}p" ${SUBJECT_LIST})

## Where the parent directory for the data should be
HCPPARENTDIR="/scratch/kg98/stuarto-HCP/Preprocessed"

SUBPARCDIR="${HCPPARENTDIR}/${SUBJECTID}/T1w/parc"

HCPSUBDIR="${HCPPARENTDIR}/${SUBJECTID}"

SUBFREESURFDIR="${HCPPARENTDIR}/${SUBJECTID}/T1w/${SUBJECTID}/"

NEWDIR="/projects/kg98/stuarto/HCP_parc/SUBJECTS"

cp -Rfv ${SUBFREESURFDIR} ${NEWDIR}

cp -Rfv ${SUBPARCDIR} ${NEWDIR}/${SUBJECTID}

cp -Rfv ${HCPSUBDIR}/T1w/T1w_acpc_dc_restore_brain.nii.gz ${NEWDIR}/${SUBJECTID}



