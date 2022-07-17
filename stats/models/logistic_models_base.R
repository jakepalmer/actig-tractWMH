#' ---
#' title: WMH and Actigraphy
#' subtitle: Logistic Model Summary
#' author: Jake Palmer
#' output:
#'    html_document:
#'        toc: true
#' params:
#'    dv: missing
#'    iv: missing
#'    prior_loc: missing
#'    prior_scale: missing
#' ---
#' 
#' **NOTE:** Inputs provided by logistic_models_master.Rmd
#' 
#' ### Supplied parameters

#' Dependent variable = `r params$dv`
#' 
#' Independent variables = `r params$iv`
#' 
#' Normal priors location = `r params$prior_loc`
#' 
#' Normal priors scale = `r params$prior_scale`
#' 
#+ warning = FALSE, message = FALSE

## Setup
library(ggplot2)
library(rstanarm)
library(bayestestR)
library(bayesplot)
library(BayesFactor)
library(fs)

options(mc.cores = parallel::detectCores())

# Set directories
scripts <- path(base, 'src')
data_processed <- path(base, 'data', 'processed')
stats_models <- path(base, 'stats', 'models')
stats_models_funcs <- path(base, 'stats', 'models', 'logistic_models_func.R')

# Check inputs
if (params$dv == "missing") {
  print("ERROR: No DV supplied")
  break
}
if (params$iv == "missing") {
  print("ERROR: No IV supplied")
  break
}
if (params$prior_loc == "missing") {
  print("ERROR: Need to supply prior locations")
}
if (params$prior_scale == "missing") {
  print("ERROR: Need to supply prior scales")
}

# Read data
file <- path(data_processed, 'WMHactig_data.csv')
df <- read.csv(file)

setwd(stats_models)

#' ### Model Specification

fit_model <- function(f, p) {
  seed <- 12345
  model <- stan_glm(
    as.formula(f),
    data = df,
    family = "binomial",
    prior = p,
    seed = seed,
    iter = 6000,
    warmup = round(1000),
    refresh = 0
  )
}
#' 
#' ### Fit Model

# Convert DV to binary numeric
df$dv <- as.factor(ifelse(df[[params$dv]] == "High", 1, 0))
f <- paste("dv ~", params$iv)
p <- normal(location = params$prior_loc, scale = params$prior_scale)
model <- fit_model(f, p)

#' ### Check Model
#'
#' #### Posterior predictive check

print(bayesplot::pp_check(model))

#' #### MCMC trace convergence

print(bayesplot::mcmc_trace(model))

#' #### Check for collinearity

print(car::vif(model))

#' #### Check for influential points
#' PSIS = pareto smoothed importance sampling.
#' *k* should ideally be less than 0.5 and can be used to represent an observations
#' influence on the posterior distribution. Observations with *k* > 0.5 should be checked closely and
#' those with *k* > 0.7 are likely to be problematic.
#'
#' See [documentation](https://mc-stan.org/loo/reference/pareto-k-diagnostic.html) for details.

lmodel <- rstanarm::loo(model, save_psis = TRUE)
print(lmodel)
plot(lmodel, label_points = TRUE)

#' ### Model Output
#'
#' #### Parameter summary
#+ warning = FALSE, message = FALSE

desc_post <- bayestestR::describe_posterior(model,
                                            rope_ci = 0.95,
                                            rope_range = c(-0.055, 0.055),
                                            ci = 0.95,
                                            diagnostic = "Rhat",
                                            test = c("pd", "rope", "BF")
)
desc_post$ROPE_Percentage <- desc_post$ROPE_Percentage * 100
desc_post[,-1] <- round(desc_post[,-1], 3)
knitr::kable(desc_post)

#' #### Plot posterior distributions
#+ warning = FALSE, message = FALSE

x <- plot(bayestestR::bayesfactor_parameters(model, null = c(-0.055, 0.055)))
print(x + xlim(-4, 4) + ylim(0, 2))

