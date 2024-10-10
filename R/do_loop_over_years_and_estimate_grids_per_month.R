#do_loop_over_years_and_estimate_grids_per_month <- function(combining_base_models, deeper_model_with_meta_models, get_grids_of_predictor_values){
  # loop over years and estimate grids per month
  strt <- Sys.time()
  for(yy in 2005:2018){
    #  yy = 2005
    
    predict_gridcell <- merge(gr2_0[year %in% yy & month %in% 1:12],
                           gr2_0_annual[year %in% yy],
                           by = c("gid", "year"))
    predict_gridcell <- merge(predict_gridcell, xy_ste, by = "gid", all.x = T)
    # remove those gid cells that have no state info but are vic/qld
    predict_gridcell <- predict_gridcell[!(gid %in% c('69487', '168493', '168492', '167498', '362318', '363310', '363311', '364303', '365296', '366289', '367282', '368275', '369268', '370261', '371255', '169487'))]
    # assume that NA is NSW as many will be coastal
    predict_gridcell[is.na(state),"state"] <- "NSW"
    # nrow(predict_gridcell)

    predict_gridcell$month <- as.factor(predict_gridcell$month)
    
    predict_gridcell <- predict_gridcell[complete.cases(predict_gridcell[,..predictor]),]
    # nrow(predict_gridcell)
    # 509292
    setDF(predict_gridcell)
    predict_gridcell <- dplyr::select(predict_gridcell,all_of(predictor))
    
    ## use xgboost
    
    #make sure Feature names stored in `object` and `newdata` are NOT different!
    # l <- sapply(test_o3_ppb_1hr_max, function(x) is.factor(x))
    # which(l)
    for(p_i in c("state", "year", "month")){
      #p_i <- "state"
      #print(p_i)
      predict_gridcell[,p_i] <- factor(predict_gridcell[,p_i], levels = levels(test_o3_ppb_1hr_max[,p_i]))
    }
    
    pred_xgboost <- SuperLearner::predict.SuperLearner(object = XGboost_nonspatialCV_final,
                                                       newdata=predict_gridcell[,predictor])
    predict_gridcell$pred_xgboost <- as.numeric(pred_xgboost$pred)
    
    ## use gbm::predict
    predict_gridcell$pred_gbm <- as.numeric(SuperLearner::predict.SuperLearner(object = gbm_nonspatialCV_final, newdata= predict_gridcell)$pred)
    
    # use rf::predict
    predict_gridcell$pred_rf <- as.numeric(SuperLearner::predict.SuperLearner(object = RF_nonspatial_CV, newdata= predict_gridcell)$pred)
    
    ##combine base models'grid cell prediction here
    stack_pred_data <- predict_gridcell[,c("pred_xgboost",  "pred_gbm", "pred_rf")]

    # make names match
    #meta_nonspatialCV_final$varNames
    names(stack_pred_data) <- c("XGBoost",    "GBM",       "RF")

    # reorder the columns to be nicer
    stack_pred_data <- stack_pred_data[,c("RF",        "GBM",       "XGBoost")]
    #str(stack_pred_data)
    
    # here is the meta model predictions
    estim_2 <- SuperLearner::predict.SuperLearner(object = meta_nonspatialCV_final, newdata= stack_pred_data)
    #str(estim_2)
    predict_gridcell$pred_deeper <- estim_2$pred
    
    
    for(mm in c(1:12)){
      # mm = 1
      for(model_todo in c("pred_deeper")){
        # model_todo = "pred_deeper"
        # OPTIONAL  ,  "pred_gbm",       "pred_xgboost", "pred_rf",
        
        #  model_todo = "pred_deeper"
        spg <- predict_gridcell[predict_gridcell$year == yy &
                               predict_gridcell$month == mm &
                               predict_gridcell$state %in% c("ACT", "NSW"),
                             c("lon_metres", "lat_metres", model_todo)]
        
        names(spg) <- c("x", "y", "z")
        coordinates(spg) <- ~ x + y
        gridded(spg) <- TRUE
        r <- raster(spg)
        # plot(r, zlim = c(10,60))
        writeRaster(r,
                    file.path(results_label,
                              paste0(model_todo,"_o3_",yy,"_",sprintf("%02d",mm),".tif"))
                    , overwrite = T)
      }
    }
    
    # end loop over whole thing per year
  }
  ed <- Sys.time()
  ed - strt
  
#}
