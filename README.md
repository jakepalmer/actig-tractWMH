WMH and Actigraphy
==============================

Analysis of automatically segmented WMH and non-parametric actigraphy to be included in thesis.

Project Organization
--------------------

```bash
.
|____ README.md
|____ start_R_session.py   <- Wrapper to run docker container
|____ data
    |____ archived         <- Archived versions of data files
    |____ processed        <- The final, canonical data sets for modeling
    |____ raw              <- The original, immutable data dump
|____ subject_data         <- Subject specific data (eg. imaging data)
|____ data_cleaning        <- Notebooks for data cleaning and imaging analysis
|____ src                  <- Source code and helper scripts for this project
|____ stats                <- Notebooks for stats with outputs
    |____ descriptives
        |____ output
    |____ models
        |____ output
```

Working Environment
--------------------

Docker container jpalm070/wmh-actig with RStudio initialised via start_R_session.py script.
