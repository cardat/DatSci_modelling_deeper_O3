#do_deeper_model_with_meta_models <- function(combining_base_models){
  #### get deeper model with the combination of meta models (without Predictors) ####
  
  ## meta models with RF,XGBOOST, mean, and glm
  
  num_cores = RhpcBLASctl::get_num_cores()
  options(mc.cores = 8)
  getOption("mc.cores")
  
  set.seed(1, "L'Ecuyer-CMRG")
  
  start <- Sys.time()

  meta_nonspatialCV_final <- mcSuperLearner(
    Y = train_o3_ppb_1hr_max_caret[,dependence],
    X = trainset_stack_4Base,
    method = "method.NNLS",
    cvControl = list(V = 10),
    SL.library = c("SL.ranger","SL.xgboost","SL.mean","SL.glmnet"))

  end <- Sys.time()

  end - start


  # for the independence testing assessment for deeper
  meta_test_pred <- SuperLearner::predict.SuperLearner(object = meta_nonspatialCV_final,
                                                       newdata= testset_stack_4Base)

  save(meta_nonspatialCV_final,
       meta_test_pred,
       file = file.path(output_dir_deeper, "O3_deeper_model_pred_without_original_Vars.Rdata"))
  # or
  #load(file = file.path(output_dir_deeper, "O3_deeper_model_pred_without_original_Vars.Rdata"))

  #### save the test set predictions for the BME blending ####
  meta_test_pred_df <- data.frame(test_o3_ppb_1hr_max[,
                                                      c('gid', 'year', 'month', 'state',
                                                        'lon_metres', 'lat_metres',
                                                        'o3_ppb_1hr_max')],
                                  pred_deeper = meta_test_pred$pred)

  head(meta_test_pred_df)
  #with(meta_test_pred_df, plot(pred_deeper, o3_ppb_1hr_max))
  #abline(0,1)
  #dir(output_dir_deeper)
  save(meta_test_pred_df,
       file = file.path(output_dir_deeper, "O3_deeper_model_pred_without_original_Vars_DF.Rdata"))
  # these can be used as soft probabilistic data to BME



  
#}
