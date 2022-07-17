#!/bin/bash

base="/Users/mq44848301/Desktop/WMHactig_working/subject_data/template"
tractseg_dir="${base}/tractseg_output/bundle_segmentations"

run_warps () {
	cd ${base}/${subj} || exit
	tname=$(echo ${tract} | cut -f 1 -d '.')
	echo ${tname}
	# ------
	echo "Template 2 Flair..."
	fixed="${base}/${subj}/flair.nii.gz"
	tmp2flair_mov="${base}/wmfod_template3D.nii.gz"
	tmp2flair_out="Template${tname}2Flair"
	# antsRegistrationSyNQuick.sh -d 3 -f ${fixed} -m ${tmp2flair_mov} -t s -o ${tmp2flair_out}_ -n 16
	# antsApplyTransforms -d 3 -r ${fixed} -i ${tractseg_dir}/${tname}.nii.gz -e 0 -t ${tmp2flair_out}_1Warp.nii.gz -t ${tmp2flair_out}_0GenericAffine.mat -o ${tmp2flair_out}.nii.gz
	# ------
	echo "Native to Flair..."
	fod3D="${base}/${subj}/wmfod3D.nii.gz"
	ntv2flair_out="Native${tname}2Flair"
	antsRegistrationSyNQuick.sh -d 3 -f ${fixed} -m ${fod3D} -t s -o ${ntv2flair_out}_ -n 16
	# antsApplyTransforms -d 3 -r ${fixed} -i ${tractseg_dir}/${tname}.nii.gz -e 0 -t ${ntv2flair_out}_1Warp.nii.gz -t ${ntv2flair_out}_0GenericAffine.mat -o ${ntv2flair_out}.nii.gz
	antsApplyTransforms -d 3 -r ${fixed} -i ${fod3D} -e 0 -t ${ntv2flair_out}_1Warp.nii.gz -t ${ntv2flair_out}_0GenericAffine.mat -o ${ntv2flair_out}.nii.gz
	# -----
	echo "Calculating overlap..."
	# fslmaths ${tmp2flair_out}.nii.gz -mul ${ntv2flair_out}.nii.gz ${tname}_TemplateNative_overlap.nii.gz
	# fslstats ${tname}_TemplateNative_overlap.nii.gz -V >> ${tname}_TemplateNative_overlap_vol.txt
	# fslstats ${tmp2flair_out}.nii.gz -V >> ${tname}_TemplateTract2Flair_vol.txt
	cd ${tractseg_dir} || exit
}

cd ${base} || exit

# 1. Run sh2peaks
# for subj in ABC_*; do
# 	cd ${subj} || exit
# 	sh2peaks wmfod.mif CSDpeaks.nii.gz -force
# 	cd subjects || exit
# done

# # 2. Run TractSeg on each subject and on template
# docker run -it --rm -v ${PWD}:/data wasserth/tractseg_container:master

# 3. Warp tract mask to native space
for subj in ABC_0031*; do
	echo ${subj}
	cd ${base}/${subj} || exit
	echo "Converting..."
	convert_in="${base}/${subj}/wmfod.mif"
	convert_out="${base}/${subj}/wmfod.nii.gz"
	# mrconvert ${convert_in} ${convert_out} -force
	echo "Splitting..."
	# fslsplit ${convert_out}
	fod3D="${base}/${subj}/wmfod3D.nii.gz"
	# mv vol0000.nii.gz ${fod3D}
	# rm vol00*
	cd ${tractseg_dir} || exit
	echo "Warping tracts..."
	for tract in ATR_*; do run_warps; done
	# for tract in CST_*; do run_warps; done
	# for tract in CG_*; do run_warps; done
	cd ${base} || exit
done

# # Removing overlapping regions from masks
# fslmaths ATR_left.nii.gz -mul CG_left.nii.gz overlap.nii
# fslmaths ATR_left.nii.gz -sub overlap.nii.gz ATR_left_subtract_overlap.nii.gz