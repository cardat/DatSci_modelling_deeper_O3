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
  cvControl = list(V = 10),
  parallel = "seq", # "multicore", #THIS DID NOT WORK AS MULTI BUT DOES AS SEQUENTIAL
  SL.library = c("SL.ranger","SL.xgboost","SL.mean","SL.glmnet"))
end <- Sys.time()

end - start
# 


save(meta_nonspatialCV_final_external,
     file = file.path(output_dir_deeper, "O3_deeper_nonspatialCV_model_without_original_Vars.Rdata"))
# or 
#load(file = file.path(output_dir_deeper, "O3_deeper_nonspatialCV_model_without_original_Vars.Rdata"))
summary(meta_nonspatialCV_final_external)



#}



do_plot_meta <- F
if(do_plot_meta){
  ## final deeper prediction
  str(meta_nonspatialCV_final_external$SL.predict)
  ## final meta models (note not using the meta_nonspatialCV_final as that is the CV one I think)
  str(meta_nonspatialCV_final_external$library.predict)
  head(meta_nonspatialCV_final_external$library.predict)
  class(meta_nonspatialCV_final_external$library.predict)
  toplot0 <- data.frame(meta_nonspatialCV_final_external$library.predict)
  head(toplot0)
  ## box plot and violins
  library(vioplot)
  head(trainset_stack_4Base)
  toplot <- rbind(
    data.frame(model = "2.RF", estimate = toplot0$SL.ranger_All),
    data.frame(model = "3.XGBoost", estimate = toplot0$SL.xgboost_All),
    data.frame(model = "1.GLMNET", estimate = toplot0$SL.glmnet_All),
    data.frame(model = "4.Deep ensemble", estimate = meta_nonspatialCV_final_external$SL.predict)
  )
  
  #par(mfrow = c(2,1))
  png("figures_and_tables/fig_metalearners_boxplots_20230924.png", res= 100, height = 550, width = 1000)
  with(toplot, boxplot(estimate ~ model, ylab = "Estimated ozone (ppb)", xlab = "Model", names = c("GLMNET", "RF", "XGBoost", "Deep ensemble")))
  dev.off()
  
  # Draw the plot
  with(toplot , vioplot( 
    estimate[model=="1.GLMNET"] , estimate[model=="2.RF"], estimate[model=="3.XGBoost"],  
    col=rgb(0.1,0.4,0.7,0.7) , names=c("GLMNET","RF","XGBoost") 
  ))
}
