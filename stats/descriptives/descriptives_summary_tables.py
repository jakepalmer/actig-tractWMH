import pandas as pd
from tableone import TableOne
# import sweetviz as sv
from pathlib import Path
import os
import numpy as np

np.seterr(all="ignore")

base = Path(
    "/Volumes/CRU/HBA/ABC_MRI/Student_and_Staff_folders/Jake/projects/WMHactig")
processed = base / "data" / "processed"
stats = base / "stats"
os.chdir(processed)

#----- Get data

df = pd.read_csv("WMHactig_data.csv", low_memory=False)

#----- Select cols for descriptives

clinical_cols = [
    "ATOS_age",
    "Sex",
    "MCI_Primary_recode",
    "ATOS_scan_type",
    "ATOS_BMI",
    "ATOS_GDS15",
    "ATOS_vascular_risk_index",
    "ATOS_PSQItot",
    "ATOS_exercise",
    "ATOS_MMSE",
    "BL_Antidep_YN"
]

actig_cols = [
    "ATOS_Actig_Standard_SE",
    "ATOS_Actig_Standard_Waketime",
    "ATOS_Actig_NonPar_IS",
    "ATOS_Actig_NonPar_IV",
	"ATOS_Actig_NonPar_RA",
    "ATOS_Actig_NonPar_L5",
    "ATOS_Actig_NonPar_M10",
    "ATOS_L5_StartTime_recode"
]

wmh_cols = [
    "ATOS_WholeBrainLesion_volume",
    # "ATOS_BiFLlesion_volume",
    # "ATOS_BiOLlesion_volume",
    # "ATOS_BiPLlesion_volume",
    # "ATOS_BiTLlesion_volume",
    # "ATOS_BSlesion_volume",
    "biATR_volume",
    # "biCST_volume",
    # "biCG_volume",
    "biSLFtot_volume",
    # "biIFO_volume",
    "biILF_volume",
    "biATR_volume_bin_median"
]
          
nonnormal = [
    "ATOS_MMSE",
    "ATOS_GDS15",
    "ATOS_BMI",
    "ATOS_exercise",
    "ATOS_Actig_Standard_SE",
    "ATOS_Actig_NonPar_RA",
    "ATOS_Actig_NonPar_L5",
    "ATOS_WholeBrainLesion_volume",
    # "ATOS_BiFLlesion_volume",
    # "ATOS_BiOLlesion_volume",
    # "ATOS_BiPLlesion_volume",
    # "ATOS_BiTLlesion_volume",
    # "ATOS_BSlesion_volume",
    "biATR_volume",
    # "biCST_volume",
    # "biCG_volume",
    "biSLFtot_volume",
    # "biIFO_volume",
    "biILF_volume"
    ]

categorical = [
    "MCI_Primary_recode",
    "Sex",
    "ATOS_vascular_risk_index",
    "ATOS_scan_type",
    "BL_Antidep_YN",
    "biATR_volume_bin_median"
    ]

cols = clinical_cols + actig_cols + wmh_cols

# Subset and round to 2 dec
df_sub = df[cols]
df_sub = df_sub.applymap(lambda x: round(x, 2) if isinstance(x, (int, float)) else x)

#----- Summary tables

### Whole sample ###
outfile_csv = stats / "descriptives" / "output" /   "descriptives_whole_sample.csv"
outfile_latex = stats / "descriptives" / "output" /   "descriptives_whole_sample.txt"

desc_table = TableOne(data=df_sub, categorical=categorical, columns=cols, nonnormal=nonnormal, decimals=2, pval=False)
# print(desc_table.tabulate(tablefmt="fancy_grid"))
# desc_table.to_csv(outfile_csv)
# desc_table.to_latex(outfile_latex)

### Grouped by MCI ###
outfile_csv = stats / "descriptives" / "output" /   "descriptives_byMCI.csv"
outfile_latex = stats / "descriptives" / "output" /   "descriptives_byMCI.txt"

grp = ["MCI_Primary_recode"]

desc_table_grp = TableOne(df, columns=cols, categorical=categorical, groupby=grp, nonnormal=nonnormal, decimals=2, pval=True)
# print(desc_table_grp.tabulate(tablefmt="fancy_grid"))
# desc_table_grp.to_csv(outfile_csv)
# desc_table_grp.to_latex(outfile_latex)

### Grouped by scan type ###
outfile_csv = stats / "descriptives" / "output" /   "descriptives_byScanType.csv"
outfile_latex = stats / "descriptives" / "output" /   "descriptives_byScanType.txt"

grp = ["ATOS_scan_type"]

desc_table_scan = TableOne(data=df, categorical=categorical, groupby=grp, nonnormal=nonnormal, columns=cols, decimals=2, pval=True)
# print(desc_table_scan.tabulate(tablefmt="fancy_grid"))
# desc_table_scan.to_csv(outfile_csv)
# desc_table_scan.to_latex(outfile_latex)

### Grouped by High-Low ATR lesion ###

cols = [
    "ATOS_age",
    "Sex",
    "MCI_Primary_recode",
    "ATOS_scan_type",
    "ATOS_BMI",
    "ATOS_GDS15",
    "ATOS_vascular_risk_index",
    # "ATOS_PSQItot",
    "ATOS_exercise",
    "ATOS_MMSE",
    "BL_Antidep_YN",
    "ATOS_WholeBrainLesion_volume_bin_median"
]

nonnormal = [
    "ATOS_MMSE",
    "ATOS_GDS15",
    "ATOS_BMI",
    "ATOS_exercise"
]

categorical = [
    "MCI_Primary_recode",
    "Sex",
    "ATOS_vascular_risk_index",
    "ATOS_scan_type",
    "BL_Antidep_YN",
    "ATOS_WholeBrainLesion_volume_bin_median"
]

outfile_csv = stats / "descriptives" / "output" / "descriptives_byWBwml.csv"
outfile_latex = stats / "descriptives" / "output" / "descriptives_byWBwml.txt"

grp = ["ATOS_WholeBrainLesion_volume_bin_median"]

desc_table_atr = TableOne(data=df, categorical=categorical, groupby=grp,
                           nonnormal=nonnormal, columns=cols, decimals=2, pval=True)
print(desc_table_atr.tabulate(tablefmt="fancy_grid"))
# desc_table_atr.to_csv(outfile_csv)
# desc_table_atr.to_latex(outfile_latex)

