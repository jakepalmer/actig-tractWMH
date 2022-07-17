FROM rocker/tidyverse:4.0.0

RUN apt-get update && apt-get install -y \
	python3 \
	python3-pip \
	&& pip3 install \
		pandas \
		numpy \
		tableone \
		pyreadstat \
		prefect \
		sweetviz

RUN sudo pip3 install -U scikit-learn

RUN R -e "install.packages('rstan', repos = 'https://cloud.r-project.org/', dependencies = TRUE)"
RUN R -e "devtools::install_github('stan-dev/rstanarm', build_vignettes = FALSE)"
RUN R -e "devtools::install_github('easystats/correlation')"

RUN install2.r --error \
		--deps TRUE \
		png \
		reticulate \
		ggpubr \
		ggExtra \
		fs \
		BayesFactor \
		bayesplot \
		see

### For debugging install problems ###
# RUN install2.r --error --deps TRUE png
# RUN install2.r --error --deps TRUE reticulate
# RUN install2.r --error --deps TRUE ggpubr
# RUN install2.r --error --deps TRUE ggExtra
# RUN install2.r --error --deps TRUE fs
# RUN install2.r --error --deps TRUE BayesFactor
# RUN install2.r --error --deps TRUE bayesplot
# RUN install2.r --error --deps TRUE see


