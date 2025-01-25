#do_external_nonspatial_10_fold_CV_with_deeper 
#' 
#### external nonspatial 10-fold CV with deeper (without original variables) ####
#' 

set.seed(1, "L'Ecuyer-CMRG")

start <- Sys.time()

meta_nonspatialCV_final_external = CV.SuperLearner(
  Y = train_o3_ppb_1hr_max_caret[,dependence],
  X = trainset_stack_4Base,
  family = gaussian(),
  method = "method.NNLS",
  cvControl = cv_control,
  parallel = "seq", # "multicore", #THIS DID NOT WORK
  SL.library = c("SL.ranger","SL.xgboost","SL.mean","SL.glmnet"))
end <- Sys.time()

end - start
# 


save(meta_nonspatialCV_final_external,
     file = "pred_without_original_vars/O3_deeper_nonspatialCV_model_without_original_Vars.Rdata")
# or 
#load(file = "pred_without_original_vars/O3_deeper_nonspatialCV_model_without_original_Vars.Rdata")
summary(meta_nonspatialCV_final_external)


if(do_plot_meta){
  ## final deeper prediction
  str(meta_nonspatialCV_final_external$SL.predict)
  ## final meta models (note not using the meta_nonspatialCV_final as that is the CV one)
  str(meta_nonspatialCV_final_external$library.predict)
  head(meta_nonspatialCV_final_external$library.predict)
  class(meta_nonspatialCV_final_external$library.predict)
  toplot0 <- data.frame(meta_nonspatialCV_final_external$library.predict)
  head(toplot0)
  ## box plot 
  head(trainset_stack_4Base)
  toplot <- rbind(
    data.frame(model = "2.RF", estimate = toplot0$SL.ranger_All),
    data.frame(model = "3.XGBoost", estimate = toplot0$SL.xgboost_All),
    data.frame(model = "1.GLMNET", estimate = toplot0$SL.glmnet_All),
    data.frame(model = "4.Deep ensemble", estimate = meta_nonspatialCV_final_external$SL.predict)
  )
  
  #par(mfrow = c(2,1))
  png(sprintf("figures_and_tables/fig_metalearners_boxplots_%s.png", run_label), res= 100, height = 550, width = 1000)
  with(toplot, boxplot(estimate ~ model, ylab = "Estimated ozone (ppb)", xlab = "Model", names = c("GLMNET", "RF", "XGBoost", "DEML final estimates"), ylim = c(10,60)))
  dev.off()
  
  ## scatter
  toplot_sct <- data.frame(
    x1.GLMNET = toplot0$SL.glmnet_All,
    x2.RF = toplot0$SL.ranger_All,
    x3.XGBoost = toplot0$SL.xgboost_All,
    x4.DEML_final_estimates = meta_nonspatialCV_final_external$SL.predict
  )
  head(toplot_sct)
  png(sprintf("figures_and_tables/fig_metalearners_scatter_%s.png", run_label), res= 100, height = 1000, width = 1000)
  # pairs(toplot_sct)
  par(mfrow=c(4,4), cex = 1.1, mar = c(1,1,1,1))
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  text(1,1,"GLMNET")
  with(toplot_sct, smoothScatter(x=x2.RF, y=x1.GLMNET, xlab = "RF ozone (ppb)", ylab = "GLMNET ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  with(toplot_sct, smoothScatter(x=x3.XGBoost, y=x1.GLMNET, xlab = "x3.XGBoost ozone (ppb)", ylab = "GLMNET ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  with(toplot_sct, smoothScatter(x=x4.DEML_final_estimates, y=x1.GLMNET, xlab = "x4.DEML_final_estimates ozone (ppb)", ylab = "GLMNET ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  text(1,1,"RF")
  with(toplot_sct, smoothScatter(x=x3.XGBoost, y=x2.RF, xlab = "XGBoost ozone (ppb)", ylab = "RF ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  with(toplot_sct, smoothScatter(x=x4.DEML_final_estimates, y=x2.RF, xlab = "x4.DEML_final_estimates ozone (ppb)", ylab = "RF ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  text(1,1,"XGBoost")
  with(toplot_sct, smoothScatter(x=x4.DEML_final_estimates, y=x3.XGBoost, xlab = "DEML final estimates ozone (ppb)", ylab = "XGBoost ozone (ppb)", xlim = c(10,60), ylim = c(10,60)))
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  plot(0:2, 0:2, type = "n", axes = F, ylab = "", xlab = "")
  text(1,1,"DEML final estimates")
  
  dev.off()
  

}
