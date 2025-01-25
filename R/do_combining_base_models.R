#do_combining_base_models 
#### Combining 4 base models ####

# ## stack ensemble model
# unify the variables' names
colnames(RF_nonspatial_CV$Z) <- RF_nonspatial_CV$libraryNames
colnames(gbm_nonspatialCV_final$Z) <- gbm_nonspatialCV_final$libraryNames
colnames(XGboost_nonspatialCV_final$Z) <- XGboost_nonspatialCV_final$libraryNames

# create stack training dataset
trainset_stack_4Base <- cbind(RF_nonspatial_CV$Z, gbm_nonspatialCV_final$Z, XGboost_nonspatialCV_final$Z)

trainset_stack_4Base <- as.data.frame(trainset_stack_4Base)
names(trainset_stack_4Base) <- c("RF","GBM","XGBoost") 

# create stack testing dataset
## keep the variable names in stack test the same as the stack training data set
testset_stack_4Base <- as.data.frame(cbind(RF_nonspatial_CV_pred$pred, gbm_nonspatialCV_final_pred$pred, XGboost_nonspatialCV_final_pred$pred))
names(testset_stack_4Base) <- c("RF","GBM","XGBoost")


if(do_plot){
## box plot and violins
head(trainset_stack_4Base)
toplot <- rbind(
  data.frame(model = "3.RF", estimate = trainset_stack_4Base$RF),
  data.frame(model = "2.XGBoost", estimate = trainset_stack_4Base$XGBoost),
  data.frame(model = "1.GBM", estimate = trainset_stack_4Base$GBM)
  )

#par(mfrow = c(2,1))
png(sprintf("figures_and_tables/fig_baselearners_boxplots_%s.png",run_label), res= 133, height = 550, width = 1000*1.25)
with(toplot, boxplot(estimate ~ model, ylab = "Estimated ozone (ppb)", xlab = "Model", names = c("GBM", "XGBoost", "RF"), cex=1))
dev.off()

## scatter
png(sprintf("figures_and_tables/fig_baselearners_scatter_%s.png",run_label), res= 100, height = 400, width = 1000)
# pairs(trainset_stack_4Base)
par(mfrow=c(1,3), cex = 1.1)
with(trainset_stack_4Base, smoothScatter(x=XGBoost, y=GBM, xlab = "XGBoost ozone (ppb)", ylab = "GBM ozone (ppb)", xlim = c(10,55), ylim = c(10,55)))#, pch = 16, cex = 0.7))
with(trainset_stack_4Base, smoothScatter(x=RF, y=GBM, xlab = "RF ozone (ppb)", ylab = "GBM ozone (ppb)", xlim = c(10,55), ylim = c(10,55)))#, pch = 16, cex = 0.7))
with(trainset_stack_4Base, smoothScatter(x=RF, y=XGBoost, xlab = "RF ozone (ppb)", ylab = "XGBoost ozone (ppb)", xlim = c(10,55), ylim = c(10,55)))#, pch = 16, cex = 0.7))
dev.off()


}