#do_xgboost_model 
  #### XGboost model ####
  #' 
  #'     we select max_depth = 7,eta = 0.3, and min_child_weight = 7, as the best parameters.
  #' 
  #' ### the XGboost model training
  #' 
  # from ALven's Powerpoint slide 6:
  '
# 4  * 4 * 4 = 64 different configurations.
tune = list(
    eta = c(0.01,0.05,0.1,0.3), #learning rate with default 0.3
    min_child_weight = c(1, 3, 5, 7),# minimum node size with default 1
    max_depth = c(1,3,5,7))# tree depth with default 6

Image shows All risk estimates are based on V = 10

Using 10 fold cross-validation (V = 10) we assessed 64 different configurations for eta (0.01,0.05,0.1,0.3), min_child_weight (1, 3, 5, 7) and max_depth (1,3,5,7). The optimal settings were eta = 0.3, min_child_weight = 7 and max_depth = 7.
'
  
  tab_hparams <- rbind(tab_hparams, 
                       data.frame(Model = "XGboost", Hyperparameters = "eta = 0.3, min_child_weight = 7 and max_depth = 7")
  )
  
  # setup parallel computation
  ##
  num_cores = RhpcBLASctl::get_num_cores()
  options(mc.cores = 4) 
  getOption("mc.cores")
  
  set.seed(1, "L'Ecuyer-CMRG")
  ##
  
  learners_xgboost = create.Learner("SL.xgboost", tune = list(eta = 0.3,
                                                              min_child_weight = 7,max_depth = 7))
  
  start <- Sys.time()
  ## XGboost model
  XGboost_nonspatialCV_final <- mcSuperLearner(Y = train_o3_ppb_1hr_max_caret[,dependence],
                                            
                                            X = train_o3_ppb_1hr_max_caret[,predictor],
                                            
                                            cvControl = list(V = 10),
                                            
                                            SL.library = c(learners_xgboost$names)) 
  
  end <- Sys.time()
  
  end - start
  
  ### independence test assessment
  
  XGboost_nonspatialCV_final_pred <- SuperLearner::predict.SuperLearner(
    object = XGboost_nonspatialCV_final,
    newdata= test_o3_ppb_1hr_max[,predictor])
  
  save(XGboost_nonspatialCV_final,XGboost_nonspatialCV_final_pred,
       file = file.path(cloudstor_dir, outdir_results, "base_models/XGBoost_model_pred.Rdata"))
  # or 
  #load(file = file.path(outdir_results, "XGBoost_model_pred.Rdata"))
 
