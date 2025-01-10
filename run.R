#### Aim: DEEP learning ozone model ####
run_label <- "20250110a"
## the test run with general-CV at first submission to ENVSOFT was
## "20241010"

## when testing the codes it is useful to run these sub-modules interactively to de-bug and troubleshoot
do_base_models <- F
do_meta_models <- F

source("R/load_packages.R")
load_packages(force_install=F)

# Load config settings
config <-source("config.R")

# NOTE THAT THE INPUT DATA FROM CARDATA ARE AVAILABLE BY REQUEST ONLY
source("R/do_data_from_CARDAT.R")

# select if using spatial-CV or general-CV
cv_type <- "spatial-CV" # "general-CV"

if(cv_type == "spatial-CV"){
  cv_control <- list(validRows = validRows_o3_ppb_1hr_max)
} else {
  cv_control <- list(V = 10)
}

source("R/do_predictors_and_response.R")

#### do_base_models ####
if(do_base_models){
source("R/do_rf_model.R")
# note this creates the first row in tab_hparams

source("R/do_xgboost_model.R")
# each time we run a model it adds to the tab_hparams
  
source("R/do_gbm_model.R")
saveRDS(tab_hparams, file = "base_models/base_models_hparams.rds")
}

load("base_models/RF_model_pred.Rdata")
load("base_models/XGBoost_model_pred.Rdata")
load("base_models/GBM_model_pred.Rdata")

#### do_meta_models ####
if(do_meta_models){
do_plot <- F
source("R/do_combining_base_models.R")

source("R/do_deeper_model_with_meta_models.R")

do_plot_meta <- F
source("R/do_external_10_fold_CV_with_deeper.R")

}

load(file = "pred_without_original_vars/O3_deeper_model_pred_without_original_Vars.Rdata")
load(file = "pred_without_original_vars/O3_deeper_nonspatialCV_model_without_original_Vars.Rdata")

source("R/do_collecting_the_R2_results_for_report.R")
# 
knitr::kable(tab_results_base, digits = 2)
tab_results_base <- tab_results_base[rev(order(tab_results_base$R2_nonspatial_cv)),]
row.names(tab_results_base) <- NULL
knitr::kable(tab_results_base, digits = 2, row.names = F)
#### store the evaluation of base learners results ####
saveRDS(tab_results_base, file = "figures_and_tables/tab_results_base.rds")

write.csv(tab_results_base, file = "figures_and_tables/tab_results_base.csv")

## the weights of meta models(with a total of 1)
meta_nonspatialCV_final$coef
# don't show test in training set
knitr::kable(tab_results_meta[,1:6], digits = c(NA,2,2,2,2,2))
write.csv(tab_results_meta[,1:6], file = "figures_and_tables/tab_results_meta.csv")

do_predict_grids <- F
if(do_predict_grids){
  source("R/do_get_grids_of_predictor_values.R")

  source("R/do_loop_over_years_and_estimate_grids_per_month.R")
}
