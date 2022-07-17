#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
# creates indexes for reference sequences
#PBS -P HBA
#PBS -N WMHactig_SS2T
#PBS -l select=1:ncpus=20:mem=120GB
#PBS -l walltime=10:00:00
#PBS -j oe
#PBS -M jake.palmer@sydney.edu.au
#PBS -m ae
#PBS -q defaultQ

# load modules
module load fsl/6.0.0
module load mrtrix3/3.0_RC3
module load ants

base="/project/RDS-FSC-HBA-RW/Jake/HBA_mrtrix/WMHactig"

# Single-tissue CSD FBA
# Pipeline based on https://mrtrix.readthedocs.io/en/latest/fixel_based_analysis/st_fibre_density_cross-section.html
# and:
# http://community.mrtrix.org/t/fixel-based-analysis-on-single-shell-data/897/6
# http://community.mrtrix.org/t/fba-single-shell-high-gm-fod-values/1746
# Created by Jake Palmer for HBA FBA actig analysis, Jul 2019 - adapted for WMH actig analysis Apr 2020.

cd ${base}/tmp || exit

# # 1 Denoising already completed on local with something like:
# foreach * : dwidenoise IN/dwi.mif IN/dwi_denoised.mif

# # 2 Motion and distortion correction
# May be done with separate scripts per subject
# foreach ${base}/subjects/ABC* : dwipreproc IN/dwi_denoise.mif IN/dwi_preproc.mif -eddyqc_all ${base}/eddy_logs -rpe_none -pe_dir PA -eddy_options " --slm=linear" -force

# # 3 Estimate temporary mask
# foreach ${base}/subjects/ABC* : dwi2mask IN/dwi_preproc.mif IN/dwi_tmp_mask.mif -force -nthreads 50

# # 4 Bias field correction
# foreach ${base}/subjects/ABC* : dwibiascorrect -ants IN/dwi_preproc.mif IN/dwi_preproc_biascorrect.mif -force -nthreads 50

# # 5 Intensity normalisation
# mkdir -p ${base}/intensity_norm/dwi_in
# mkdir ${base}/intensity_norm/mask_in

# cd ${base}/subjects || exit
# for subj in ABC_*; do
# 	cd ${subj}
# 	cp dwi_preproc_biascorrect.mif ${base}/intensity_norm/dwi_in/
# 	mv ${base}/intensity_norm/dwi_in/dwi_preproc_biascorrect.mif ${base}/intensity_norm/dwi_in/${subj}.mif
# 	cd ${base}/subjects || exit
# done

# cd ${base}/subjects || exit
# for subj in ABC_*; do
# 	cd ${subj}
# 	cp dwi_tmp_mask.mif ${base}/intensity_norm/mask_in/
# 	mv ${base}/intensity_norm/mask_in/dwi_tmp_mask.mif ${base}/intensity_norm/mask_in/${subj}.mif
# 	cd ${base}/subjects || exit
# done

# # foreach ABC* : ln -s ./IN/dwi_preproc_biascorrect.mif ${base}/intensity_norm/dwi_in/IN.mif
# # foreach ABC* : ln -s ./IN/dwi_tmp_mask.mif ${base}/intensity_norm/mask_in/IN.mif 

# dwiintensitynorm ${base}/intensity_norm/dwi_in ${base}/intensity_norm/mask_in ${base}/intensity_norm/dwi_output ${base}/intensity_norm/fa_template.mif ${base}/intensity_norm/fa_template_wm_mask.mif -force  -nthreads 50

# cd ${base}/intensity_norm/dwi_output
# for img in ABC*; do
# 	name=$(echo ${img} | cut -f 1 -d '.')
# 	ln -s $img ${base}/subjects/$name/dwi_normalised.mif
# 	cp ./${img} ${base}/subjects/$name
# 	mv ${base}/subjects/$name/$img ${base}/subjects/$name/dwi_normalised.mif
# done

# # 6 Compute mean response function
# # This step differs to standard single-shell FBA, and follows http://community.mrtrix.org/t/fixel-based-analysis-on-single-shell-data/897/5
# foreach ${base}/subjects/ABC* : dwi2response dhollander IN/dwi_normalised.mif IN/response_wm.txt IN/response_gm.txt IN/response_csf.txt -force -nthreads 50
# average_response ${base}/subjects/ABC*/response_wm.txt ${base}/mean_response_wm.txt -force -nthreads 50
# average_response ${base}/subjects/ABC*/response_csf.txt ${base}/mean_response_csf.txt -force -nthreads 50

# # 7 Upsampling - resample to isotropic voxel size
# foreach ${base}/subjects/ABC* : mrresize IN/dwi_normalised.mif -vox 1.3 IN/dwi_normalised_upsamp.mif -force -nthreads 50

# # 8 Upsampled brainmask
# foreach ${base}/subjects/ABC* : dwi2mask IN/dwi_normalised_upsamp.mif IN/dwi_mask.mif -force -nthreads 50

###############
# Check brainmasks before continuing
###############

# 9 CSD
# This step differs to standard single-shell FBA, and follows http://community.mrtrix.org/t/fixel-based-analysis-on-single-shell-data/897/5
# foreach ${base}/subjects/ABC* : dwi2fod msmt_csd IN/dwi_normalised_upsamp.mif ${base}/mean_response_wm.txt IN/wmfod.mif ${base}/mean_response_csf.txt IN/csf.mif -mask IN/dwi_mask.mif -force -nthreads 20

# 10 Study specific FOD template
# template_subjects=$(<${base}/template_subjects.txt)

# mkdir -p ${base}/template/fod_in
# mkdir -p ${base}/template/mask_in

# for subj in $template_subjects; do
#     cd ${base}/subjects/$subj
#     cp wmfod.mif ${base}/template/fod_in/${subj}_wmfod_norm.mif
#     cp dwi_mask.mif ${base}/template/mask_in/${subj}_dwi_mask.mif
# done

population_template ${base}/template/fod_in -mask_dir ${base}/template/mask_in ${base}/template/wmfod_template.mif -voxel_size 1.3 -force

# 11 Register all FOD images to FOD template
foreach ${base}/subjects/ABC* : mrregister IN/wmfod.mif -mask1 IN/dwi_mask.mif ${base}/template/wmfod_template.mif -nl_warp IN/subject2template_warp.mif IN/template2subject_warp.mif -force

# 12 Compute template mask
foreach ${base}/subjects/ABC* : mrtransform IN/dwi_mask.mif -warp IN/subject2template_warp.mif -interp nearest -datatype bit IN/dwi_mask_tempspace.mif -force
mrmath ${base}/subjects/ABC*/dwi_mask_tempspace.mif min ${base}/template/template_mask.mif -datatype bit -force