#!/bin/bash
#SBATCH --job-name=euler_number
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

# clean modules
module purge
module load freesurfer/7.1.0
 
# set paths
SUBJECTS_DIR=/path/to/fs_dir # fill in
outdir=/path/to/outdir # fill in
dataset=<dataset_name> # fill in
numbers='^[0-9]+$'
f=${outdir}/${dataset}_holes_temp.txt
id=${outdir}/${dataset}_ids.txt
e=${outdir}/${dataset}_holes.csv

for i in `cat ~/kg98/path/to/fs_sublist.txt` ; do # fill in
for h in lh rh ; do
    x=$(mris_euler_number ${SUBJECTS_DIR}/${i}/surf/${h}.orig.nofix | grep -o -P '(?<=--> ).*(?= holes)')
    if [[ $x =~ $numbers ]] ; then
    echo $x >> $f
    echo ${i}_${h} >> ${id}
    fi
  done
done

paste -d "," ${id} ${f} > ${e}
rm ${id}
rm ${f}
####

# technically this only returns the number of holes on the surface but you can calculate euler number as a function of this number with 2 - 2n where n is the number this script returns
