#!/bin/bash

base_dir="/Volumes/BMRI/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/subject_data"
template_tractseg_dir="${base_dir}/template/tractseg_output/bundle_segmentations"
flair_dir="${base_dir}/flair"

run_warps () {
	tname=$(echo ${tract} | cut -f 1 -d '.')
	cd ${subj_dir} || exit
	echo ${tname}
	echo "Template 2 Flair..."
	fixed=${subj}.nii.gz
	tmp2flair_mov="${base_dir}/template/wmfod_template3D.nii.gz"
	tmp2flair_out="Template${tname}2Flair"
	antsRegistrationSyNQuick.sh -d 3 -f ${fixed} -m ${tmp2flair_mov} -t s -o ${tmp2flair_out}_ -n 16
	antsApplyTransforms -d 3 -r ${fixed} -i ${template_tractseg_dir}/${tname}.nii.gz -e 0 -t ${tmp2flair_out}_1Warp.nii.gz -t ${tmp2flair_out}_0GenericAffine.mat -o ${tmp2flair_out}.nii.gz
	# Remove intermediate files to save disk space on local
	rm Template*Warp*
	rm Template*mat
	cd ${template_tractseg_dir} || exit
}

cd ${flair_dir} || exit

for subj in ABC_*; do
	echo ${subj}
	subj_dir="${flair_dir}/${subj}"
	cd ${template_tractseg_dir} || exit
	echo "Warping tracts..."
	for tract in ATR_*; do run_warps; done
	for tract in CST_*; do run_warps; done
	for tract in CG_*; do run_warps; done
	for tract in SLF_I_*; do run_warps; done
	# for tract in T_PREF_*; do run_warps; done
	for tract in SLF_II_*; do run_warps; done
	for tract in SLF_III_*; do run_warps; done
	# for tract in ILF_*; do run_warps; done
	for tract in IFO_*; do run_warps; done
	cd ${flair_dir} || exit
done