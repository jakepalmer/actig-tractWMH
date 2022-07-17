#!/bin/bash

base="/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/data/wmfod_template"
cd ${base} || exit

# Organise XNAT download
for dir in ABC_*; do 
    echo ${dir}
    mv ${dir}/*/DICOM/ ${dir}/
done

# Denoise
echo "Denoising..."
foreach ${base}/ABC* : dwidenoise IN/DICOM/ IN/dwi_denoise.mif -noise IN/dwi_noise.mif
echo "DONE"