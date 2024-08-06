#!/bin/bash
#SBATCH --account=kg98
#SBATCH --job-name=gif_dhcp_surface
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time 2:00:00
#SBATCH --mail-user=alexander.holmes1@monash.edu
#SBATCH --mail-type=FAIL
#SBATCH --mail-type=END
#SBATCH --array=1-217

# this one is very scuffed and doesn't run well on SLURM - it also takes ages to run in a terminal so it's mainly just for pretty demonstrative purposes than actual QC

# text file to list of subject IDs - make sure to also change the previous array option to the range of this text file
SUB_LIST="/path/to/sublist.txt"

#SLURM_ARRAY_TASK_ID=1
sub=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${SUB_LIST})
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
tmpdir=${outdir}/${subject}_work

if [ ! -d $tmpdir ]; then mkdir -d $tmpdir; echo "making work directory"; fi

T1=${datadir}/${sub}/anat/${sub}_T1w.nii.gz # BIDS format
lhpial=${fsdir}/${sub}/surf/lh.pial # freesurfer output format - if you're not loading in fs files, change this to whatever surface you have (e.g., ${sub}_hemi-left_pial.surf.gii)
rhpial=${fsdir}/${sub}/surf/rh.pial # freesurfer output format
lhwhite=${fsdir}/${sub}/surf/lh.white # freesurfer output format
rhwhite=${fsdir}/${sub}/surf/rh.white # freesurfer output format

# this next part is why this script is so cooked - you'll need to change the number of slices in the for loop to however many slices your T1s have
# I might come up with a method to read the T1 vol and count the slices then interate upon that (e.g., fslmaths ...), but this timelapse isn't important so it's a very low priority

# sagittal
for slice in 020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 ; do
vglrun fsleyes render -of ${tmpdir}/${sub}_${ses}_sagittal${slice}.png --hidey --hidez --voxelLoc ${slice} 145 145 --scene ortho ${T1} ${lhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${rhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${lhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1} ${rhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1}
done

convert -delay 13 -loop 0 ${tmpdir}/*sagittal*.png ${outdir}/${sub}_${ses}_sagittal_surf.gif

# coronal
for slice in 020 021 022 023 024 025 026 027 028 029 030 031 032 033 034 035 036 037 038 039 040 041 042 043 044 045 046 047 048 049 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255 256 257 258 259 260 ; do
vglrun fsleyes render -of ${tmpdir}/${sub}_${ses}_coronal${slice}.png --hidex --hidez --voxelLoc 108 ${slice} 145 --scene ortho ${T1} ${lhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${rhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${lhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1} ${rhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1}
done

convert -delay 13 -loop 0 ${tmpdir}/*coronal*.png ${outdir}/${sub}_${ses}_coronal_surf.gif

# axial
for slice in 050 051 052 053 054 055 056 057 058 059 060 061 062 063 064 065 066 067 068 069 070 071 072 073 074 075 076 077 078 079 080 081 082 083 084 085 086 087 088 089 090 091 092 093 094 095 096 097 098 099 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 ; do
vglrun fsleyes render -of ${tmpdir}/${sub}_${ses}_axial${slice}.png --hidex --hidey --voxelLoc 108 145 ${slice} --scene ortho ${T1} ${lhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${rhpial} --colour 0.0 0.0 1.0 --outline --outlineWidth 2.0 -r ${T1} ${lhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1} ${rhwhite} --colour 1.0 0.0 0.0 --outline --outlineWidth 2.0 -r ${T1}
done

convert -delay 13 -loop 0 ${tmpdir}/*axial*.png ${outdir}/${sub}_${ses}_axial_surf.gif

rm -r ${tmpdir}

# for reference if unfamiliar with 3d views/terminology
# sagittal x
# coronal y
# axial z

