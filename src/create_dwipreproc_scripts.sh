#!/bin/bash

hpc_base="/project/RDS-FSC-HBA-RW/Jake/HBA_mrtrix/WMHactig"

cd /Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/data/wmfod_template || exit
for subj in ABC*; do
    cat > /Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/src/dwipreproc_pbs/${subj}_dwipreproc.sh << EOF

#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#
# creates indexes for reference sequences
#PBS -P HBA
#PBS -N WMHactig_${subj}
#PBS -l select=1:ncpus=10:mem=32GB
#PBS -l walltime=10:00:00
#PBS -j oe
#PBS -M jake.palmer@sydney.edu.au
#PBS -m ae
#PBS -q defaultQ

# load modules
module load fsl/6.0.0
module load mrtrix3/3.0_RC3
module load ants

base=${hpc_base}
mkdir -p ${hpc_base}/eddy_logs/${subj} || exit
cd ${hpc_base}/tmp

# 1 Denoising already completed on local

# 2 Motion and distortion correction
dwipreproc ${hpc_base}/subjects/${subj}/dwi_denoise.mif ${hpc_base}/subjects/${subj}/dwi_preproc.mif -eddyqc_all ${hpc_base}/eddy_logs/${subj} -rpe_none -pe_dir PA -eddy_options " --slm=linear" -force

EOF

done