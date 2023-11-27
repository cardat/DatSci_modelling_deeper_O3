# do_rf_model 
  #### RF model ####
  #' 
  #'     We keep default num.trees = 500 and select mtry = 150 and min.node.size = 50 for our final model parameters.
  #'     Alven shows in the Powerpoint slide 3 and 4: 
  '
tuneGrid <- data.frame(
        .mtry = c(3,10,20,50,100,150),
        .splitrule = "variance",
        .min.node.size = c(50)
)


tuneGrid2 <- data.frame(
.mtry = c(150),
.splitrule = "variance",
.min.node.size = 
c(50,100, 200,500,1000))

The Random Forest hyper-parameters were tuned first using a grid search across mtry (from 3,10,20,50,100,150) and a constant min.node.size. Then mtry was held constant at a value of 150 and the optimal min.nod.size (from 50,100, 200,500,1000) was selected that minimised the RMSE was 50.
'
#'     STORE THIS INFORMATION FOR REPORTING
tab_hparams <- data.frame(Model = "Random forest", Hyperparameters = "num.trees = 500 mtry = 150 and min.node.size = 50")

learners_rf = create.Learner("SL.ranger", tune = list(mtry = 150, min.node.size = 50))

start <- Sys.time()
## random forest model
# changed cvControl = list(validRows = validRows_o3_ppb_1hr_max),
RF_nonspatial_CV <- SuperLearner(Y = train_o3_ppb_1hr_max_caret[,dependence],
                              
                              X = train_o3_ppb_1hr_max_caret[,predictor],
                              
                              cvControl = list(V = 10), 
                              
                              SL.library = c(learners_rf$names)) 

end <- Sys.time()

end - start
matrix(names(RF_nonspatial_CV))

### independence test assessment

RF_nonspatial_CV_pred <- SuperLearner::predict.SuperLearner(object = RF_nonspatial_CV,
                                                         newdata= test_o3_ppb_1hr_max[,predictor])

save(RF_nonspatial_CV, RF_nonspatial_CV_pred,
     file = file.path(cloudstor_dir, outdir_results, "base_models/RF_model_pred.Rdata"))
# or
# load(file = file.path(outdir_results, "RF_model_pred.Rdata"))
