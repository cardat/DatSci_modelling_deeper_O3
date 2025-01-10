#do_gbm_model 
'
NOT SHOWN HERE
We tuned the GBM model by keeping n.minobsinnode constant at 20 and varying shrinkage (0.01, 0.1, 0.3), n.trees (100, 200, 500), and interaction.depth (1, 3, 5). The optimal settings were shrinkage = 0.1, n.trees = 200, and interaction.depth = 3.
'

tab_hparams <- rbind(tab_hparams, 
                     data.frame(Model = "GBM", Hyperparameters = "shrinkage = 0.1, gbm.trees = c(200), interaction.depth = 3, n.minobsinnode = 20")
)

learners_gbm = create.Learner("SL.gbm", tune = list(shrinkage = c(.1), gbm.trees = c(200), interaction.depth = c(3),n.minobsinnode = 20))

start <- Sys.time()
## GBM model
gbm_nonspatialCV_final <- SuperLearner(Y = train_o3_ppb_1hr_max_caret[,dependence],
                                       
                                       X = train_o3_ppb_1hr_max_caret[,predictor],
                                       
                                       cvControl = cv_control,
                                       
                                       SL.library = c(learners_gbm$names)) 

end <- Sys.time()

end - start


gbm_nonspatialCV_final_pred <- SuperLearner::predict.SuperLearner(
  object = gbm_nonspatialCV_final,
  newdata= test_o3_ppb_1hr_max[,predictor])

save(gbm_nonspatialCV_final,gbm_nonspatialCV_final_pred,
     file = "base_models/GBM_model_pred.Rdata")
# or
#load(file = file.path("base_models", "GBM_model_pred.Rdata"))



