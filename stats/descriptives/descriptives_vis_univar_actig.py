import pandas as pd
import sweetviz as sv
from pathlib import Path
import os
import numpy as np

np.seterr(all='ignore')

base = Path("/home/WMHactig")
processed = base / "data" / "processed"
stats = base / "stats"
os.chdir(processed)

#----- Get data

df = pd.read_csv("WMHactig_data.csv", low_memory=False)

#----- Select cols for descriptives
cols = [
    'ATOS_Actig_Standard_SE',
    'ATOS_Actig_Standard_SE_curt',
    'ATOS_Actig_NonPar_IS',
    'ATOS_Actig_NonPar_IS_curt',
    'ATOS_Actig_NonPar_IV',
    'ATOS_Actig_NonPar_IV_curt',
	'ATOS_Actig_NonPar_RA',
    'ATOS_Actig_NonPar_RA_curt',
    'ATOS_Actig_NonPar_L5',
    'ATOS_Actig_NonPar_L5_curt',
    'ATOS_L5_StartTime_recode',
    'ATOS_L5_StartTime_recode_curt',
	'ATOS_Actig_NonPar_M10',
	'ATOS_Actig_NonPar_M10_curt'
]

#----- Visualisation withh SweetViz

df_sub = df[cols]
outfile = stats / "descriptives" / "output" / "descriptives_vis_univar_actig.html"

report = sv.analyze(df_sub)
report.show_html(outfile)
