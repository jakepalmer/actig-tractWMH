#!/anaconda3/envs/working/bin/python3

from prefect import task, Flow
from prefect.tasks.shell import ShellTask
import pandas as pd
from pathlib import Path
import os
import glob
from functools import reduce
import csv

base_dir = Path("/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig")
subj_dir = base_dir / "subject_data"
src_dir = base_dir / "src"
data_dir = base_dir / "data" / "processed"
data_file = data_dir / "WMHactig_data.csv"
sienax_dir = subj_dir / "sienax"

#----- Define tasks for workflow


# @task(name="Convert txt to csv")
def txt2csv(pattern):
	os.chdir(subj_dir)
	for file in glob.glob(pattern):
		infile = file
		outfile = file.split('.')[0] + ".csv"
		with open(infile) as fin, open (outfile, 'w') as fout:
				out=csv.writer(fout)
				for line in fin:
					out.writerow(line.split())
		os.remove(file)


# @task(name="Rename csv cols with tract label")
def rename_columns(pattern):
	os.chdir(subj_dir)
	for file in glob.glob(pattern):
		df = pd.read_csv(file, low_memory=False)
		tract_label = file.replace("_stats.csv", "")
		new_vox_col = tract_label + '_' + 'voxels'
		new_vol_col = tract_label + '_' + 'volume'
		df.columns = ['ID', new_vox_col, new_vol_col]
		df.to_csv(file, index=False)


# @task(name="Merge all tract level stats")
def merge_tract_stats(pattern):
	os.chdir(subj_dir)
	file_list = []
	for file in glob.glob(pattern):
		file_list.append(file)
	file_list.append("DateTime.csv")
	dfs = (pd.read_csv(f) for f in file_list)
	df_tracts = reduce(lambda  left,right: pd.merge(left,right,on=['ID'], how='left'), dfs).fillna('NA')
	return df_tracts


# @task(name="Get sienax scaling factor")
def get_sienax_scaling(pattern):
	ID = []
	scaling = []
	os.chdir(sienax_dir)
	for subj in glob.glob(pattern):
		ID.append(subj)
		infile = sienax_dir / subj / 'report.sienax'
		txt = []
		with open(infile) as file:
			for line in file:
				line = line.strip()
				txt.append(line)
		vscaling = [s for s in txt if 'VSCALING' in s]
		scaling_factor = vscaling[0].split()[1]
		scaling.append(scaling_factor)
	df_scaling = pd.DataFrame(list(zip(ID, scaling)), columns = ['ID', 'sienax_scaling_factor'])
	df_scaling.to_csv('scaling_test.csv')
	return df_scaling


# @task(name="Merge and write final output")
def merge_final(df1, df2):
	os.chdir(subj_dir)
	df_out = pd.merge(df1, df2, on=['ID'], how='left')
	df_out.to_csv("all_tract_lesion_stats.csv", index=False)
	return df_out


# @task(name="Merge with master data")
def merge_master(df, master_file):
	df_master = pd.read_csv(master_file, low_memory=False)
	newID = df['ID'].str.split('_', expand=True)
	df['ABC_ID'] = newID[0] + '_' + newID[1]
	df.drop(columns = ['ScanDate', 'ScanTime', 'scan_type', 'ID'], inplace=True)
	df_master = pd.merge(df_master, df, on=['ABC_ID'], how='left')
	os.chdir(data_dir)
	# df_master.to_csv(master_file, index=False)
	df_master.to_csv("WMHactig_data_tmp.csv", index=False)


# Helper for shell tasks
cmd = "cd {}".format(str(src_dir))
sh_task = ShellTask(helper_script=cmd)


#----- Define and run registration worflow

with Flow("Derive tract lesion stats") as workflow:
	# mask2subj = sh_task(command='bash mask2subj.sh')
	tract_lesion_masks = sh_task(command='bash create_tract_lesion_masks.sh')
	tract_stat_extract = sh_task(command='bash extract_tract_lesion_stats.sh')

workflow.run()

#----- Define and run post-reg routine

def main():
	txt2csv(pattern="*.txt")
	rename_columns(pattern="*_stats.csv")
	df_tracts = merge_tract_stats(pattern="*_stats.csv")
	df_scaling = get_sienax_scaling(pattern="ABC_1184*")
	df_out = merge_final(df1=df_tracts, df2=df_scaling)
	# df_final = merge_master(df_out, data_file)

main()
