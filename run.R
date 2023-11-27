do_base_models <- F
do_meta_models <- F

#### Aim: DEEP learning ozone model ####
# version statement: 
## 2023-08-01 Change from spatial CV to random 10 percent
## 2021-10-4th to 8th ivanhanigan added maximum temperature to the dataset and re-ran the codes. This script is modified from the original codes whicher were converted from Alven's Rmd to R script using knitr::purl("20210802_APMMA_O3_final.Rmd"), with notes found in cloudstor\Shared\ResearchProjects_CAR\Air_pollution_modelling_APMMA\modelling_DEEPER\20210802_O3_deeper\
#20210802_base and deeper model performance.pptx

source("R/load_packages.R")
load_packages(force_install=F)

# NEW first set the path locations
cloudstor_dir <- "~/onedrive/Shared/A_SURE_STANDARD_STAGING"
datadir <- file.path(cloudstor_dir,"Air_pollution_modelling_APMMA/modelling_general/")
# setwd(paste0(cloudstor_dir))
# getwd()
# now were we will save the results
run_label <- "20230710_O3_deeper_without_spatial_cv"
outdir_results <- file.path("Air_pollution_modelling_APMMA/modelling_DEEPER", run_label)
if(!file.exists("base_models")) dir.create("base_models")
# create a sub directory for storing these deeper results
output_dir_deeper <- file.path(cloudstor_dir, outdir_results, "pred_without_original_vars")
if(!file.exists(output_dir_deeper)) dir.create(output_dir_deeper, recursive = T)

if(!file.exists("figures_and_tables")) dir.create("figures_and_tables")

# create a folder for these GeoTIF results
results_label <- "results_o3_20230803"
outdir_results_tifs <- file.path(cloudstor_dir, paste0("/Air_pollution_modelling_APMMA/modelling_DEEPER/o3_monthly/", results_label))
if(!file.exists(outdir_results_tifs)) dir.create(outdir_results_tifs, recursive = T)

source("R/do_data_from_Nico.R")

source("R/do_predictors_and_responce.R")
 

#### do_base_models ####
if(do_base_models){
source("R/do_rf_model.R")
# note this creates the first row in tab_hparams

source("R/do_xgboost_model.R")

source("R/do_gbm_model.R")
saveRDS(tab_hparams, file = file.path(cloudstor_dir, outdir_results, "base_models/base_models_hparams.rds"))
}

load(file.path(cloudstor_dir, outdir_results, "base_models/RF_model_pred.Rdata"))
load(file.path(cloudstor_dir, outdir_results, "base_models/XGBoost_model_pred.Rdata"))
load(file.path(cloudstor_dir, outdir_results, "base_models/GBM_model_pred.Rdata"))

#### do_meta_models ####
if(do_meta_models){
source("R/do_combining_base_models.R")

source("R/do_deeper_model_with_meta_models.R")

source("R/do_external_nonspatial_10_fold_CV_with_deeper.R")

}

load(file = file.path(output_dir_deeper, "O3_deeper_model_pred_without_original_Vars.Rdata"))
load(file = file.path(output_dir_deeper, "O3_deeper_nonspatialCV_model_without_original_Vars.Rdata"))

source("R/do_collecting_the_R2_results_for_report.R")
# 
knitr::kable(tab_results_base, digits = 2)
tab_results_base <- tab_results_base[rev(order(tab_results_base$R2_nonspatial_cv)),]
row.names(tab_results_base) <- NULL
knitr::kable(tab_results_base, digits = 2, row.names = F)
#### store the evaluation of base learners results ####
saveRDS(tab_results_base, file = file.path(file.path(cloudstor_dir, outdir_results, "tab_results_base.rds")))

## the weights of meta models(with a total of 1)
meta_nonspatialCV_final$coef
# don't show test in training set
knitr::kable(tab_results_meta[,1:6], digits = c(NA,2,2,2,2,2))

# do_predict_grids <- F
# if(do_predict_grids){
#   source("R/do_get_grids_of_predictor_values.R")
#   
#   source("R/do_loop_over_years_and_estimate_grids_per_month.R")
# }
# 
# 
# 
