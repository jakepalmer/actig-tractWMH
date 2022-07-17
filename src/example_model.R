model_fit <- function(f) {
  print("Fitting model...")
  f <- as.formula(f)
  model <- stan_glm(f,
                    data = df,
                    prior = normal(0, 1), 
                    chains = 4,
                    iter = 10000,
                    warmup = round(2000),
                    refresh = 0)
  return(model)
}

model_check <- function(model) {
  print("Model checks...")
  color_scheme_set("viridis")
  # Trace plot
  print(bayesplot::mcmc_trace(model))
  # Posterior predictive check
  print(bayesplot::pp_check(model))
  # lm assumptions
  print(performance::check_model(lm(f, data = df)))
  # Cook's distance
  # formula <- as.formula(FORMULA)
  mod <- lm(f, data=df)
  cooksd <- cooks.distance(mod)
  plot(cooksd, pch="*", cex=2, main="Influential Obs by Cooks distance")
  abline(h = 4*mean(cooksd, na.rm=T), col="red")
  text(x=1:length(cooksd)+1, y=cooksd, 
       labels=ifelse(cooksd>4*mean(cooksd, na.rm=T),names(cooksd),""), col="red")
  # DFFITS
  plot(dffits(mod), ylab="DFFITS")
  # Combination of large residuals and high leverage indicative of influential outliers
  plot(mod, which=5)
}

model_outputs <- function(model) {
  # Summary
  rope_range <- as.list(rope_range(model))
  params <- bayestestR::describe_posterior(model, test = c('pd', 'rope'), rope_ci = 1)
  BF_ROPE <- bayestestR::bayesfactor(model, null = rope_range(model))
  params$BF_ROPE <- BF_ROPE$BF
  params <- format(params, digits = 2)
  print(params)
  # pd
  pd_tab <- bayestestR::p_direction(model)
  print(pd_tab)
  # Equivalence test
  equiv_tab <- bayestestR::equivalence_test(model, ci = 1)
  print(equiv_tab)
  # Plot posterior distributions
  x <- plot(bayestestR::bayesfactor_parameters(model, null = rope_range(model)))
  print(x)
}

model_runner <- function(f) {
  print(f)
  model <- model_fit(f)
  model_check(model)
  model_outputs(model)
}