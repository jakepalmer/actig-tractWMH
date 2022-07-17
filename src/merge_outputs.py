import pandas as pd
from pathlib import Path
import os
import glob
from functools import reduce
import csv

base_dir = Path("/Users/mq44848301/Desktop/WMHactig_working/subject_data")
sienax_dir = base_dir / "sienax"
os.chdir(base_dir)

#----- Convert tract stat txt to csv

print("Converting txt to csv...")
for file in glob.glob("*.txt"):
	infile = file
	outfile = file.split('.')[0] + ".csv"
	with open(infile) as fin, open (outfile, 'w') as fout:
			out=csv.writer(fout)
			for line in fin:
				out.writerow(line.split())

#----- Add tract identifier to tract lesion stats files before merging

print("Adding tract identifier...")
for file in glob.glob('*_stats.csv'):
	df = pd.read_csv(file, low_memory=False)
	tract_label = file.replace("_stats.csv", "")
	new_vox_col = tract_label + '_' + 'voxels'
	new_vol_col = tract_label + '_' + 'volume'
	df.columns = ['ID', new_vox_col, new_vol_col]
	df.to_csv(file, index=False)

#----- Merge all tract stat csv's

print("Merging tract lesion stat files...")
file_list = []

for file in glob.glob("*_stats.csv"):
	file_list.append(file)
file_list.append("DateTime.csv")

dfs = (pd.read_csv(f) for f in file_list)
df_tracts = reduce(lambda  left,right: pd.merge(left,right,on=['ID'], how='left'), dfs).fillna('NA')

#----- Get scaling factors from sienax reports and merge

print("Getting sienax scaling factors...")
ID = []
scaling = []

os.chdir(sienax_dir)
for subj in glob.glob("xABC_00*"):
	ID.append(subj)
	infile = sienax_dir / subj / "report.sienax"
	txt = []
	with open(infile) as file:
		for line in file:
			line = line.strip()
			txt.append(line)
	vscaling = [s for s in txt if "VSCALING" in s]
	scaling_factor = vscaling[0].split()[1]
	scaling.append(scaling_factor)

df_scaling = pd.DataFrame(list(zip(ID, scaling)), columns = ['ID', 'sienax_scaling_factor'])

#----- Merge scaling and tract data for final output

print("Final output...")
os.chdir(base_dir)
df_out = pd.merge(df_scaling, df_tracts, on=['ID'], how='left') 
df_out.to_csv("all_tract_lesion_stats.csv", index=False)

print("Done!")