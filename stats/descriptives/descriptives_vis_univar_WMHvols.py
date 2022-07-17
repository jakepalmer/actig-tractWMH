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
    'ATOS_WholeBrainLesion_volume',
    'ATOS_BSlesion_volume',
    'ATOS_LFLlesion_volume',
    'ATOS_RFLlesion_volume',
    'ATOS_LOLlesion_volume',
    'ATOS_ROLlesion_volume',
    'ATOS_LPLlesion_volume',
    'ATOS_RPLlesion_volume',
    'ATOS_LTLlesion_volume',
    'ATOS_RTLlesion_volume',
    'ATOS_BiFLlesion_volume',
    'ATOS_BiOLlesion_volume',
    'ATOS_BiPLlesion_volume',
    'ATOS_BiTLlesion_volume',
    'ATR_left_volume',
    'ATR_right_volume',
    'biATR_volume',
    'CST_left_volume',
    'CST_right_volume',
    'biCST_volume',
    'CG_left_volume',
    'CG_right_volume',
    'biCG_volume',
    'SLF_I_left_volume',
    'SLF_I_right_volume',
    'biSLF_I_volume',
    'biT_PREF_volume',
    'biSLF_II_volume',
    'biSLF_III_volume',
    'biILF_volume',
    'biSLFtot_volume',
    'biIFO_volume'
]

new_cols = []

for col in cols:
    s = col + '_scaled'
    new_cols.extend([col, s])

#----- Visualisation withh SweetViz

df_sub = df[new_cols]
outfile = stats / "descriptives" / "output" / "descriptives_vis_univar_WMHvols.html"

report = sv.analyze(df_sub)
report.show_html(outfile)
