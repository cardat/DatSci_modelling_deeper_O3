# do_rf_model 
'
NOT SHOWN HERE
The Random Forest hyper-parameters were tuned first using a grid search across mtry (from 3,10,20,50,100,150) and a constant min.node.size. Then mtry was held constant at a value of 150 and the optimal min.nod.size (from 50,100, 200,500,1000) was selected that minimised the RMSE was 50.
'
#'     STORE THIS INFORMATION FOR REPORTING
tab_hparams <- data.frame(Model = "Random forest", Hyperparameters = "num.trees = 500 mtry = 150 and min.node.size = 50")

learners_rf = create.Learner("SL.ranger", tune = list(mtry = 150, min.node.size = 50))

start <- Sys.time()
## random forest model

RF_nonspatial_CV <- SuperLearner(Y = train_o3_ppb_1hr_max_caret[,dependence],
                              
                              X = train_o3_ppb_1hr_max_caret[,predictor],
                              
                              cvControl = cv_control,
                              
                              SL.library = c(learners_rf$names)) 

end <- Sys.time()

end - start
matrix(names(RF_nonspatial_CV))

### independence test assessment

RF_nonspatial_CV_pred <- SuperLearner::predict.SuperLearner(object = RF_nonspatial_CV,
                                                         newdata= test_o3_ppb_1hr_max[,predictor])

save(RF_nonspatial_CV, RF_nonspatial_CV_pred,
     file = "base_models/RF_model_pred.Rdata")
# or IF DE-BUGGING
# load(file = file.path("base_models", "RF_model_pred.Rdata"))
