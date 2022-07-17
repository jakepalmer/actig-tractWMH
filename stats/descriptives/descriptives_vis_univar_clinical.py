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
    'ATOS_age',
    'MCI_Primary_recode',
    'ATOS_BMI',
    'ATOS_GDS15',
    'ATOS_vascular_risk_index',
    'ATOS_PSQItot',
    'ATOS_exercise',
    'ATOS_MMSE'
]

#----- Visualisation withh SweetViz

df_sub = df[cols]
outfile = stats / "descriptives" / "output" / "descriptives_vis_univar_clinical.html"

report = sv.analyze(df_sub)
report.show_html(outfile)
