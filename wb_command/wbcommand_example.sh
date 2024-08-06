################################################################################
#                            Start wb_command                                  #
################################################################################
module load connectome


################################################################################
#                   User inputs - feel free to change                          #
################################################################################
HCP=/mnt/reference2/hcp1200 # Location of HCP data root folder; this should contain the subjects within (i.e. ./100206, ./100307)
SCHAEFER=. # Location of schaefer parcellation (e.g. Schaefer2018_100Parcels_17Networks_order.dlabel.nii)
PARCEL=100 # Number of Schaefer parcels
ID=100206  # HCP subject ID


################################################################################
#                               More setup                                     #
################################################################################
hcp_cifti_file=Atlas_MSMAll_hp2000_clean
r1=rfMRI_REST1_LR
r2=rfMRI_REST1_RL
tmp_name=fMRI_CONCAT_REST1 # Naming convention for concatenated fMRI timeseries
IDP=./${ID}

CIFTI_dt_ext=${hcp_cifti_file}.dtseries.nii 
CIFTI_pt_ext=${hcp_cifti_file}.ptseries.nii 
CIFTI_pconn_ext=${hcp_cifti_file}.pconn.nii 
mkdir -p ${ID}


################################################################################
#                               Calculations                                   #
################################################################################

# Demean timeseries
for p in ${r1} ${r2}; do
    wb_command -cifti-reduce ${HCP}/${ID}/MNINonLinear/Results/${p}/${p}_${CIFTI_dt_ext} MEAN ${IDP}/${p}_mean.dscalar.nii
    wb_command -cifti-math '(x-mean)' -fixnan 0 -var x ${HCP}/${ID}/MNINonLinear/Results/${p}/${p}_${CIFTI_dt_ext} \
	-var mean ${IDP}/${p}_mean.dscalar.nii -select 1 1 -repeat ${IDP}/${p}_demean_${CIFTI_dt_ext}
done 

# Perform Concatenation of the rsfMRI timeseries
wb_command -cifti-merge ${IDP}/${tmp_name}_${CIFTI_dt_ext} \
-cifti ${IDP}/${r1}_demean_${CIFTI_dt_ext} \
-cifti ${IDP}/${r2}_demean_${CIFTI_dt_ext} 

# Average time series over Schaefer Parcellation
wb_command -cifti-parcellate ${IDP}/${tmp_name}_${CIFTI_dt_ext} \
${SCHAEFER}/Schaefer2018_${PARCEL}Parcels_17Networks_order.dlabel.nii \
COLUMN ${IDP}/${tmp_name}_schaefer_${PARCEL}_${CIFTI_pt_ext}

# Compute the FC Matrix and Save to output directory 
wb_command -cifti-correlation ${IDP}/${tmp_name}_schaefer_${PARCEL}_${CIFTI_pt_ext} \
${IDP}/${tmp_name}_FC_MATRIX_schaefer_${PARCEL}_${CIFTI_pconn_ext}
 