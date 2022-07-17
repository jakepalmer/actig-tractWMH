#!/bin/bash

# subjects=$(<'/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig/data/processed/subjects.txt')
flair='/Volumes/CRU/HBA/ABC_MRI/MRI_Data/WMH/flair'
seg='/Volumes/CRU/HBA/ABC_MRI/MRI_Data/WMH/whole_brain_lesion_masks'

cd ${flair} || exit

for subj in ABC*; do
	for img in ${subj}*; do
		echo $img
		mrview -load $img -mode 2 -fullscreen -roi.load $seg/$img -roi.opacity 0.1
	done
done