#!/bin/bash

#$ -S /bin/bash
#$ -cwd
#
# creates indexes for reference sequences
#PBS -P HBA
#PBS -N ants_reg
#PBS -l select=1:ncpus=10:mem=64GB
#PBS -l walltime=20:00:00
#PBS -j oe
#PBS -M jake.palmer@sydney.edu.au
#PBS -m ae
#PBS -q defaultQ

# load modules
module load ants
module load fsl/5.0.9

base_dir="/project/RDS-FSC-HBA-RW/Jake/WMHactig"
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

for subj in ABC_0382*; do
	echo ${subj}
	subj_dir="${flair_dir}/${subj}"
	cd ${template_tractseg_dir} || exit
	echo "Warping tracts..."
	# for tract in ATR_*; do run_warps; done
	# for tract in CST_*; do run_warps; done
	# for tract in CG_*; do run_warps; done
	# for tract in SLF_I_*; do run_warps; done
	# for tract in T_PREF_*; do run_warps; done
	# for tract in SLF_II_*; do run_warps; done
	# for tract in SLF_III_*; do run_warps; done
	# for tract in ILF_*; do run_warps; done
	for tract in IFO_*; do run_warps; done
	cd ${flair_dir} || exit
done