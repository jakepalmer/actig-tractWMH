#!/bin/bash

base_dir="/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/subject_data"
wb_lesion_mask_dir="/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/subject_data/whole_brain_lesion_masks"

#----- Create tract level masks

cd ${base_dir}/"flair" || exit
for subj in ABC_1184*; do
    echo ${subj}
    mkdir -p ${base_dir}/"flair"/${subj}/tract_lesion_masks
    cd ${subj} || exit
    for tract in *2Flair.nii.gz; do
        t=$(echo ${tract} | cut -d "2" -f 1)
        tname=${t:8}
        fslmaths ${wb_lesion_mask_dir}/${subj}.nii.gz -mul ${tract} ${base_dir}/"flair"/${subj}/tract_lesion_masks/${tname}_lesion_mask.nii.gz
    done
    cd ${base_dir}/"flair" || exit
done

