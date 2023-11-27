#do_get_grids_of_predictor_values <- function(grid_to_use){
  # get grids of predictor values. Note that we tested three ideas
  # 1. exclude points where any predictor outside the training data range (was a plan until found such high percent would be missing ~85%)
  # 2. constrain the predictor values to the limits of the data range
  # 3. use the raw data values, and flag the cells that are A) any predictor outside range or B) any prediction outside the range
  
  # we found too many missing for option 1 so went with option 2.
  # NOTE also I did not regenerate the raw grid with maxtmp after finding it was missing, so only use constrained now
  
  indir_est_grd <- file.path(cloudstor_dir, "/Air_pollution_modelling_APMMA/GIS_predictors_from_CARDAT/data_derived_for_predicting")
  dir(indir_est_grd, pattern = "20211004")
  
  grid_to_use <- "constrained" # or choose "raw" for option 3
  
  # 2.
  if(grid_to_use == "constrained"){
    
    gr2_0<- readRDS(file.path(indir_est_grd, "apmma_est_grd_20211004_5km_nsw_mly_o3_no2_2005_2018_monthly_scaled_constrained_v2.rds"))
    str(gr2_0)
    
    gr2_0_annual <- readRDS(file.path(indir_est_grd,"apmma_est_grd_20211004_5km_nsw_mly_o3_no2_2005_2018_annual_scaled_constrained_v2.rds"))
    
  }
  
  # 3.
  if(grid_to_use == "raw"){
    gr2_0<- readRDS(file.path(indir_est_grd, "apmma_est_grd_20210716_5km_nsw_mly_o3_no2_2005_2018_monthly_scaled.rds"))
    gr2_0_annual <- readRDS(file.path(indir_est_grd,"apmma_est_grd_20210716_5km_nsw_mly_o3_no2_2005_2018_annual_scaled.rds"))
  }
  
  names(gr2_0)
  # set this to a data.table for merging quicker
  setDT(gr2_0)
  names(gr2_0_annual)
  setDT(gr2_0_annual)
  
  # get the grid cell to state table (created in in GIS_Predictors_from_CARDAT/ script 'constrain - to data limits'.R)
  xy_ste <- readRDS(file.path(indir_est_grd, "apmma_est_grd_xy_state_20210915.rds"))
  
#}
