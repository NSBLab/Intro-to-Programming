#!/bin/bash
#SBATCH --job-name=freeview_plots
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

SUBJECT_LIST="/path/to/sublist.txt"

#SLURM_ARRAY_TASK_ID=1
sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUBJECT_LIST})
echo -e "\t\t\t --------------------------- "
echo -e "\t\t\t ----- ${SLURM_ARRAY_TASK_ID} ${subject} ----- "
echo -e "\t\t\t --------------------------- \n"

module purge
module load fsleyes

# paths
# this all assumes BIDS btw
datadir=/path/to/dataset # change this
fsdir=/path/to/dataset/derivatives/freesurfer # change this - if your surfaces aren't freesurfer format (e.g., .surf.gii instead of .pial or .white), so long as this path leads to where the GIFTIs are
outdir=/path/to/output/surf_vis # change this

T1=${datadir}/${sub}/anat/${sub}_T1w.nii.gz # BIDS format
lhpial=${fsdir}/${sub}/surf/lh.pial # freesurfer output format - if you're not loading in fs files, change this to whatever surface you have (e.g., ${sub}_hemi-left_pial.surf.gii)
rhpial=${fsdir}/${sub}/surf/rh.pial # freesurfer output format
lhwhite=${fsdir}/${sub}/surf/lh.white # freesurfer output format
rhwhite=${fsdir}/${sub}/surf/rh.white # freesurfer output format

# you can change a lot of these parameters here if you want a slightly different slice location, etc

vglrun fsleyes render -of ${outdir}/${sub}_surface.png --scene ortho --worldLoc 21.63228391654404 3.260162353515625 4.367583011312568 --displaySpace ${T1} --xcentre -0.24892 -0.12806 --ycentre -0.40344 -0.12806 --zcentre -0.40344 -0.24892 --xzoom 88.64813445998706 --yzoom 88.64813445998706 --zzoom 80.06904359637748 --layout horizontal --bgColour 0.0 0.0 0.0 --fgColour 1.0 1.0 1.0 --cursorColour 0.0 1.0 0.0 --colourBarLocation top --colourBarLabelSide top-left --colourBarSize 100.0 --labelSize 12 --performance 3 --movieSync \
${T1} --name "${sub}_T1w" --overlayType volume --alpha 100.0 --brightness 50.0 --contrast 50.0 --cmap greyscale --negativeCmap greyscale --displayRange 0.0 38.64319990765954 --clippingRange 0.0 39.029631906736135 --gamma 0.0 --cmapResolution 256 --interpolation none --numSteps 60 --blendFactor 0.3 --smoothing 0 --resolution 70 --numInnerSteps 10 --clipMode intersection --volume 0 \
${lhpial} --name "${sub}_hemi-left_pial" --overlayType mesh --alpha 100.0 --brightness 50.0 --contrast 50.0 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet ${lhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 --refImage ${T1} --coordSpace affine --unlinkLowRanges --displayRange 0.0 1.0 --clippingRange 0.0 1.01 --gamma 0.0 --cmapResolution 256 \
${rhpial} --name "${sub}_hemi-right_pial" --overlayType mesh --alpha 100.0 --brightness 50.0 --contrast 50.0 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet ${rhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 --refImage ${T1} --coordSpace affine --unlinkLowRanges --displayRange 0.0 1.0 --clippingRange 0.0 1.01 --gamma 0.0 --cmapResolution 256 \
${lhwhite} --name "${sub}_hemi-left_wm" --overlayType mesh --alpha 100.0 --brightness 50.0 --contrast 50.0 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet ${lhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 --refImage ${T1} --coordSpace affine --unlinkLowRanges --displayRange 0.0 1.0 --clippingRange 0.0 1.01 --gamma 0.0 --cmapResolution 256 \
${rhwhite} --name "${sub}_hemi-right_wm" --overlayType mesh --alpha 100.0 --brightness 50.0 --contrast 50.0 --lut random --cmap greyscale --negativeCmap greyscale --vertexDataIndex 0 --vertexSet ${rhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 --refImage ${T1} --coordSpace affine --unlinkLowRanges --displayRange 0.0 1.0 --clippingRange 0.0 1.01 --gamma 0.0 --cmapResolution 256


