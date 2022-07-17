#!/bin/bash

base_dir="/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/subject_data"
wb_lesion_mask_dir="/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/subject_data/whole_brain_lesion_masks"

#----- Extract tract level lesion volumes

cd ${base_dir}/"flair" || exit

# Write output files with headings for each tract
pattern="ABC_1184*"
subj=( $pattern )
cd ${base_dir}/"flair"/${subj[0]}/tract_lesion_masks || exit
for tract_mask in *.nii.gz; do
	tname=${tract_mask::${#tract_mask}-19}
	echo "ID voxels volume" >> ${base_dir}/${tname}_stats.txt
done

# Get vols for each subject
cd ${base_dir}/"flair" || exit
for subj in ABC_1184*; do
	echo ${subj}
	cd ${base_dir}/"flair"/${subj}/tract_lesion_masks || exit
	for tract_mask in *.nii.gz; do
		tname=${tract_mask::${#tract_mask}-19}
		vols=$(fslstats ${tract_mask} -V)
		echo ${subj} ${vols} >> ${base_dir}/${tname}_stats.txt
    done
    cd ${base_dir}/"flair"  || exit
done