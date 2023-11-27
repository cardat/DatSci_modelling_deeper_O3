#do_loop_over_years_and_estimate_grids_per_month <- function(combining_base_models, deeper_model_with_meta_models, get_grids_of_predictor_values){
  # loop over years and estimate grids per month
  strt <- Sys.time()
  for(yy in 2005:2016){
    #  yy = 2005
    
    test_gridcell <- merge(gr2_0[year %in% yy & month %in% 1:12], 
                           gr2_0_annual[year %in% yy],
                           by = c("gid", "year"))
    test_gridcell <- merge(test_gridcell, xy_ste, by = "gid", all.x = T)
    # remove those gid cells that have no state info but are vic/qld
    test_gridcell <- test_gridcell[!(gid %in% c('69487', '168493', '168492', '167498', '362318', '363310', '363311', '364303', '365296', '366289', '367282', '368275', '369268', '370261', '371255', '169487'))]
    # assume that NA is NSW as many will be coastal
    test_gridcell[is.na(state),"state"] <- "NSW"
    #nrow(test_gridcell)
    # 620352
    
    test_gridcell$month <- as.factor(test_gridcell$month)
    
    test_gridcell <- test_gridcell[complete.cases(test_gridcell[,..predictor]),]
    #nrow(test_gridcell)
    # 509304 
    setDF(test_gridcell)
    test_gridcell <- dplyr::select(test_gridcell,all_of(predictor))
    
    ## use xgboost
    
    #make sure Feature names stored in `object` and `newdata` are NOT different!
    #l <- sapply(test_o3_ppb_1hr_max, function(x) is.factor(x))
    #which(l)
    for(p_i in c("state", "year", "month")){
      #p_i <- "state"
      #print(p_i)
      test_gridcell[,p_i] <- factor(test_gridcell[,p_i], levels = levels(test_o3_ppb_1hr_max[,p_i]))
    }
    
    pred_xgboost <- SuperLearner::predict.SuperLearner(object = XGboost_nonspatialCV_final,
                                                       newdata=test_gridcell[,predictor])
    test_gridcell$pred_xgboost <- as.numeric(pred_xgboost$pred)
    
    ## use gbm::predict
    test_gridcell$pred_gbm <- as.numeric(SuperLearner::predict.SuperLearner(object = gbm_nonspatialCV_final, newdata= test_gridcell)$pred)
    
    # use rf::predict
    test_gridcell$pred_rf <- as.numeric(SuperLearner::predict.SuperLearner(object = RF_nonspatial_CV, newdata= test_gridcell)$pred)
    
    ## NOTRUN use mgcv::gam predict
    # excluding spacetime
    # test_gridcell$pred_spacetime <- as.numeric(predict(fit_model3_final_non_linear, test_gridcell))
    
    
    ## OLD note from Alven:
    #stack_pred_data <- cbind(base_model1$prediction,base_model2$prediction,...) 
    ##combine base models'grid cell prediction here
    
    stack_pred_data <- test_gridcell[,c("pred_xgboost",  "pred_gbm", "pred_rf")]
    # exclude "pred_spacetime",
    
    # make names match
    #meta_nonspatialCV_final$varNames
    
    names(stack_pred_data) <- c("XGBoost",    "GBM",       "RF")
    # rm "spacetime",
    # reorder the columns to be nicer
    stack_pred_data <- stack_pred_data[,c("RF",        "GBM",       "XGBoost")]
    # rm "spacetime"
    #str(stack_pred_data)
    
    # here is the meta model predictions
    estim_2 <- SuperLearner::predict.SuperLearner(object = meta_nonspatialCV_final, newdata= stack_pred_data)
    #str(estim_2)
    test_gridcell$pred_deeper <- estim_2$pred
    
    
    for(mm in c(1:12)){
      # mm = 1
      for(model_todo in c("pred_deeper")){
        #  ,  "pred_gbm",       "pred_xgboost", "pred_rf",       
        # rm   "pred_spacetime",
        
        #  model_todo = "pred_deeper"
        spg <- test_gridcell[test_gridcell$year == yy & 
                               test_gridcell$month == mm & 
                               test_gridcell$state %in% c("ACT", "NSW"),
                             c("lon_metres", "lat_metres", model_todo)]
        
        names(spg) <- c("x", "y", "z")
        coordinates(spg) <- ~ x + y
        gridded(spg) <- TRUE
        r <- raster(spg)
        # plot(r, zlim = c(10,60))
        writeRaster(r,
                    file.path(outdir_results_tifs,
                              paste0(model_todo,"_o3_",yy,"_",sprintf("%02d",mm),".tif"))
                    , overwrite = T)
      }
    }
    
    # end loop over whole thing per year
  }
  ed <- Sys.time()
  ed - strt
  
#}
