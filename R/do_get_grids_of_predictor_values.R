#do_get_grids_of_predictor_values <- function(grid_to_use){

  # NB Data avaliable by request only
  indir_est_grd <- file.path(cloudstor_dir, "/Air_pollution_modelling_APMMA/GIS_predictors_from_CARDAT/data_derived_for_predicting")

  gr2_0<- readRDS(file.path(indir_est_grd, "apmma_est_grd_20211004_5km_nsw_mly_o3_no2_2005_2018_monthly_scaled_constrained_v2.rds"))
  str(gr2_0)
    
  gr2_0_annual <- readRDS(file.path(indir_est_grd,"apmma_est_grd_20211004_5km_nsw_mly_o3_no2_2005_2018_annual_scaled_constrained_v2.rds"))

  names(gr2_0)
  # set this to a data.table for merging quicker
  setDT(gr2_0)
  names(gr2_0_annual)
  setDT(gr2_0_annual)
  
  # get the grid cell to state table (created in in GIS_Predictors_from_CARDAT/ script 'constrain - to data limits'.R)
  xy_ste <- readRDS(file.path(indir_est_grd, "apmma_est_grd_xy_state_20210915.rds"))
  
#}
