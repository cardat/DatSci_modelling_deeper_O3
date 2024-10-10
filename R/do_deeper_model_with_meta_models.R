#do_deeper_model_with_meta_models <- function(combining_base_models){
  #### get deeper model with the combination of meta models (without Predictors) ####
  
  ## meta models with RF,XGBOOST, mean, and glm
  
  num_cores = RhpcBLASctl::get_num_cores()
  options(mc.cores = 8)
  # NB the Rstudio I used failed but Emacs with ESS worked.
  # Rstudio complained with:
  # [777436:777436:20241010,121507.642674:ERROR elf_dynamic_array_reader.h:61] tag not found
  # [777436:777436:20241010,121507.642700:ERROR elf_dynamic_array_reader.h:61] tag not found
  # Error in Z[unlist(validRows, use.names = FALSE), ] <- do.call("rbind",  : 
  #                                                                 number of items to replace is not a multiple of replacement length
  #                                                               In addition: Warning message:
  #                                                                 In parallel::mclapply(validRows, FUN = .crossValFUN, Y = Y, dataX = X,  :
  #                                                                                         scheduled cores 1, 2 did not deliver results, all values of the jobs will be affected
  # Rstudio version I tested was
  # RStudio 2023.06.1+524 "Mountain Hydrangea" Release (547dcf861cac0253a8abb52c135e44e02ba407a1, 2023-07-05) for Ubuntu Focal
  # Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) rstudio/2023.06.1+524 Chrome/110.0.5481.208 Electron/23.3.0 Safari/537.36
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
       file = "pred_without_original_vars/O3_deeper_model_pred_without_original_Vars.Rdata")
  # or
  # load(file = "pred_without_original_vars/O3_deeper_model_pred_without_original_Vars.Rdata")

  #### save the test set predictions for the BME blending ####
  meta_test_pred_df <- data.frame(test_o3_ppb_1hr_max[,
                                                      c('gid', 'year', 'month', 'state',
                                                        'lon_metres', 'lat_metres',
                                                        'o3_ppb_1hr_max')],
                                  pred_deeper = meta_test_pred$pred)

  # head(meta_test_pred_df)
  # with(meta_test_pred_df, plot(pred_deeper, o3_ppb_1hr_max))
  # abline(0,1)

  save(meta_test_pred_df,
       file = "pred_without_original_vars/O3_deeper_model_pred_without_original_Vars_DF.Rdata")
  # these can be used as soft probabilistic data to BME



  
#}
