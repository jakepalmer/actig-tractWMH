#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
# creates indexes for reference sequences
#PBS -P HBA
#PBS -N WMHactig_SS2T
#PBS -l select=1:ncpus=5:mem=16GB
#PBS -l walltime=05:00:00
#PBS -j oe
#PBS -M jake.palmer@sydney.edu.au
#PBS -m ae
#PBS -q defaultQ

# load modules
module load mrtrix3/3.0_RC3

base="/project/RDS-FSC-HBA-RW/Jake/HBA_mrtrix/WMHactig/subjects"

for subj in ABC_*; do
	sh2peaks ${base}/${subj}/wmfod.mif ${base}/${subj}/CSDpeaks.nii.gz -force
done