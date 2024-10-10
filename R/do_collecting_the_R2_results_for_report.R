# do_collecting_the_R2_results_for_report
#### RF ####

### assessment with nonspatial CV
R2_nonspatial_cv <- apply(RF_nonspatial_CV$Z, 2, caret::R2, 
                       obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

RMSE_nonspatial_cv <- apply(RF_nonspatial_CV$Z, 2, caret::RMSE, 
                         obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


### training assessment with whole final model
apply(RF_nonspatial_CV$library.predict, 2, caret::R2, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)
apply(RF_nonspatial_CV$library.predict, 2, caret::RMSE, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

### independence test assessment

# RF_nonspatial_CV_pred <- SuperLearner::predict.SuperLearner(object = RF_nonspatial_CV, 
#                                                          newdata= test_o3_ppb_1hr_max[,predictor])

R2_test <- apply(RF_nonspatial_CV_pred$pred, 2, caret::R2, 
                 obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)

RMSE_test <- apply(RF_nonspatial_CV_pred$pred, 2, caret::RMSE, 
                   obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)


tab_results_base <- data.frame(Model = "Random Forest",
                               vars = length(predictor),	
                               R2_nonspatial_cv = R2_nonspatial_cv,
                               RMSE_nonspatial_cv = RMSE_nonspatial_cv,
                               R2_test = R2_test,
                               RMSE_test = RMSE_test)
#### xgb ####

### assessment with nonspatial CV
R2_nonspatial_cv_xgb <- apply(XGboost_nonspatialCV_final$Z, 2, caret::R2, 
                           obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

RMSE_nonspatial_cv_xgb <- apply(XGboost_nonspatialCV_final$Z, 2, caret::RMSE, 
                             obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


### training assessment with whole final model
apply(XGboost_nonspatialCV_final$library.predict, 2, caret::R2, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)
# SL.xgboost_1_All 

apply(XGboost_nonspatialCV_final$library.predict, 2, caret::RMSE, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


### independence test assessment

#XGboost_nonspatialCV_final_pred <- SuperLearner::predict.SuperLearner(
#  object = XGboost_nonspatialCV_final, 
#  newdata= test_o3_ppb_1hr_max[,predictor])

R2_test_xgb <- apply(XGboost_nonspatialCV_final_pred$pred, 2, caret::R2, 
                     obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)

RMSE_test_xgb <- apply(XGboost_nonspatialCV_final_pred$pred, 2, caret::RMSE, 
                       obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)



tab_results_base <- rbind(tab_results_base,
                          data.frame(Model = "XGboost",
                                     vars = length(predictor),	
                                     R2_nonspatial_cv = R2_nonspatial_cv_xgb,
                                     RMSE_nonspatial_cv = RMSE_nonspatial_cv_xgb,
                                     R2_test = R2_test_xgb,
                                     RMSE_test = RMSE_test_xgb)
)
#### gbm ####

### assessment with nonspatial CV
R2_nonspatial_cv_gbm <- apply(gbm_nonspatialCV_final$Z, 2, caret::R2, 
                           obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

RMSE_nonspatial_cv_gbm <- apply(gbm_nonspatialCV_final$Z, 2, caret::RMSE, 
                             obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


### training assessment with whole final model
apply(gbm_nonspatialCV_final$library.predict, 2, caret::R2, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)
# SL.gbm_1_All 

apply(gbm_nonspatialCV_final$library.predict, 2, caret::RMSE, 
      obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


### independence test assessment

R2_test_gbm <- apply(gbm_nonspatialCV_final_pred$pred, 2, caret::R2, 
                     obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)

RMSE_test_gbm <- apply(gbm_nonspatialCV_final_pred$pred, 2, caret::RMSE, 
                       obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)


tab_results_base <- rbind(tab_results_base,
                          data.frame(Model = "GBM",
                                     vars = length(predictor),	
                                     R2_nonspatial_cv = R2_nonspatial_cv_gbm,
                                     RMSE_nonspatial_cv = RMSE_nonspatial_cv_gbm,
                                     R2_test = R2_test_gbm,
                                     RMSE_test = RMSE_test_gbm)
)

#### tab_results_meta ####
## Meta learners results:
# nonspatial CV meta model results
R2_nonspatial_cv_meta <- apply(meta_nonspatialCV_final$Z, 2, caret::R2, 
                            obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

RMSE_nonspatial_cv_meta <- apply(meta_nonspatialCV_final$Z, 2, caret::RMSE, 
                              obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)
#RMSE:


### training assessment with whole final meta model
R2_train_meta <- apply(meta_nonspatialCV_final$library.predict, 2, caret::R2, 
                       obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)
# NB I had to do a quick check what it means that I get warning
# Warning message:
#In cor(obs, pred, use = ifelse(na.rm, "complete.obs", "everything")) :
#  the standard deviation is zero
# when I try to use apply on all library.predict
# but it returns a result OK, with NA for SL.mean_ALL
R2_train_meta 

# I notice that the mean is unvarying.  Refering to website: "We include the mean of Y ("SL.mean") as a benchmark algorithm. It is a very simple prediction so the more complex algorithms should do better than the sample mean. We hope to see that it isn't the best single algorithm (discrete winner) and has a low weight in the weighted-average ensemble. If it is the best algorithm something has likely gone wrong." (https://cran.r-project.org/web/packages/SuperLearner/vignettes/Guide-to-SuperLearner.html#fit-multiple-models) 
# So this is OK, cannot get R2 because mean_All is gobal mean of Y

RMSE_train_meta <- apply(meta_nonspatialCV_final$library.predict, 2, caret::RMSE, 
                         obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


## final deeper results:
### training final deeper model
R2_train_deeper <- apply(meta_nonspatialCV_final$SL.predict, 2, caret::R2, 
                         obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

RMSE_train_deeper <- apply(meta_nonspatialCV_final$SL.predict, 2, caret::RMSE, 
                           obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)


# ### independence testing assessment for deeper
# NOTE: this is the main DEEPER test R2. Note that the nonspatial R2 is calculated using CV.SuperLearner down further
meta_test_pred_R2 <- apply(meta_test_pred$pred, 2, caret::R2, 
                           obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)

# this is the metamodels
meta_test_pred_R2_mmodels <- apply(meta_test_pred$library.predict, 2, caret::R2, 
                                   obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)


# moving on, do the main deeper RMSE test
meta_test_pred_RMSE <- apply(meta_test_pred$pred, 2, caret::RMSE, 
                             obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)

# this is the metamodels
meta_test_pred_RMSE_mmodels <- apply(meta_test_pred$library.predict, 2, caret::RMSE, 
                                     obs = test_o3_ppb_1hr_max$o3_ppb_1hr_max)


## the weights of meta models(with a total of 1)
meta_nonspatialCV_final$coef

# store these results
tab_results_meta <- data.frame(Model = c("Meta Random Forest","Meta XGboost","Benchmark (Mean of Y)","Meta GLMNET"),
                               SL_weights = meta_nonspatialCV_final$coef,
                               R2_nonspatial_cv = R2_nonspatial_cv_meta,
                               RMSE_nonspatial_cv = RMSE_nonspatial_cv_meta,
                               R2_test = meta_test_pred_R2_mmodels,
                               RMSE_test = meta_test_pred_RMSE_mmodels,
                               R2_train = R2_train_meta,
                               RMSE_train = RMSE_train_meta)
row.names(tab_results_meta) <- NULL
tab_results_meta <- tab_results_meta[rev(order(tab_results_meta$R2_nonspatial_cv)),]
knitr::kable(tab_results_meta, digits = c(NA,3,2,2,2,2,2,2))

#### deeper ####
## final results
R2_nonspatial_cv_deeper <- caret::R2(meta_nonspatialCV_final_external$SL.predict,
                                  meta_nonspatialCV_final_external$Y) 


# NB it is interesting to explain the difference between this CV.SL and the mcSL from above
# compare to train_R2 from prior mcSUperLearner fit (meta_test_pred_R2)
caret::R2(meta_nonspatialCV_final$SL.predict, 
          obs = train_o3_ppb_1hr_max_caret$o3_ppb_1hr_max)

# the former is the R2 from the predicted values from the CV.SuperLearner (equivalent to the Z	= The Z matrix (the cross-validated predicted values for each algorithm in SL.library) which is for a single leaner call to SL as per RF, XGB and GBM above. 
# whereas the latter is the predicted values from the mcSuperLearner, which is the final weighted ensemble predicted values from the super learner for the rows in newX. 
# so that makes sense to me now.


RMSE_nonspatial_cv_deeper <- caret::RMSE(meta_nonspatialCV_final_external$SL.predict,
                                      meta_nonspatialCV_final_external$Y)


## an alternative is to estimate R2 across each nonspatial fold results and then average
fold1 <- apply(meta_nonspatialCV_final_external$AllSL$'1'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'1',dependence])
fold2 <- apply(meta_nonspatialCV_final_external$AllSL$'2'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'2',dependence])
fold3 <- apply(meta_nonspatialCV_final_external$AllSL$'3'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'3',dependence])
fold4 <- apply(meta_nonspatialCV_final_external$AllSL$'4'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'4',dependence])
fold5 <- apply(meta_nonspatialCV_final_external$AllSL$'5'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'5',dependence])
fold6 <- apply(meta_nonspatialCV_final_external$AllSL$'6'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'6',dependence])
fold7 <- apply(meta_nonspatialCV_final_external$AllSL$'7'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'7',dependence])
fold8 <- apply(meta_nonspatialCV_final_external$AllSL$'8'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'8',dependence])
fold9 <- apply(meta_nonspatialCV_final_external$AllSL$'9'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'9',dependence])
fold10 <- apply(meta_nonspatialCV_final_external$AllSL$'10'$SL.predict, 2, caret::R2, obs = train_o3_ppb_1hr_max_caret[meta_nonspatialCV_final_external$folds$'10',dependence])
## ...(10 folds in total)
## and we check this is pretty much the same thing 
R2_nonspatial_cv_deeper_mu_folds <- mean(c(fold1,fold2,fold3,fold4,fold5, fold6,fold7,fold8,fold9,fold10))

# plot(1:10, c(fold1,fold2,fold3,fold4,fold5, fold6,fold7,fold8,fold9,fold10))
# abline(h=R2_nonspatial_cv_deeper_mu_folds)
# worst fold4 with R2 around 0.69
# dev.off()
# we will add the deep ensemble below the meta learners results in the summary
tab_results_meta
# TODO: note that we get the deeper test set R2 "meta_test_pred_R2" and "R2_train_deeper" from the mcSL further up and the R2_nonspatial here by doing 'external nonspatial 10-fold' using the CV.SL
tab_results_meta <- rbind(tab_results_meta,
                          data.frame(Model = c("DEEPER"),
                                     SL_weights =NA,
                                     R2_nonspatial_cv = R2_nonspatial_cv_deeper,
                                     RMSE_nonspatial_cv = RMSE_nonspatial_cv_deeper,
                                     R2_test = meta_test_pred_R2,
                                     RMSE_test = meta_test_pred_RMSE,
                                     R2_train = R2_train_deeper,
                                     RMSE_train = RMSE_train_deeper)
)
row.names(tab_results_meta) <- NULL
knitr::kable(tab_results_meta, digits = c(NA,3,2,2,2,2,2,2))
