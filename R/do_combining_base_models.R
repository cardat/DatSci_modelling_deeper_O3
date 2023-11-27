#do_combining_base_models 
#### Combining 4 base models ####

# ## stack ensemble model
# unify the variables' names
colnames(RF_nonspatial_CV$Z) <- RF_nonspatial_CV$libraryNames
colnames(gbm_nonspatialCV_final$Z) <- gbm_nonspatialCV_final$libraryNames
colnames(XGboost_nonspatialCV_final$Z) <- XGboost_nonspatialCV_final$libraryNames

# create stack training dataset
trainset_stack_4Base <- cbind(RF_nonspatial_CV$Z, gbm_nonspatialCV_final$Z, XGboost_nonspatialCV_final$Z)
## NB we excluded spacetime from DEEPER 
# , train_pred_spacetime_o3$pred_spacetime)
trainset_stack_4Base <- as.data.frame(trainset_stack_4Base)
names(trainset_stack_4Base) <- c("RF","GBM","XGBoost") #,"spacetime")

# create stack testing dataset
## keep the variable names in stack test the same as the stack training data set
testset_stack_4Base <- as.data.frame(cbind(RF_nonspatial_CV_pred$pred, gbm_nonspatialCV_final_pred$pred, XGboost_nonspatialCV_final_pred$pred))
## we exclude spacetime from DEEPER 
#  ,test_pred_spacetime_o3$pred_spacetime))
names(testset_stack_4Base) <- c("RF","GBM","XGBoost")#,"spacetime")

do_plot <- F
if(do_plot){
## box plot and violins
library(vioplot)
head(trainset_stack_4Base)
toplot <- rbind(
  data.frame(model = "3.RF", estimate = trainset_stack_4Base$RF),
  data.frame(model = "2.XGBoost", estimate = trainset_stack_4Base$XGBoost),
  data.frame(model = "1.GBM", estimate = trainset_stack_4Base$GBM)
  )

#par(mfrow = c(2,1))
png("figures_and_tables/fig_baselearners_boxplots_20230924.png", res= 100, height = 550, width = 1000)
with(toplot, boxplot(estimate ~ model, ylab = "Estimated ozone (ppb)", xlab = "Model", names = c("GBM", "XGBoost", "RF")))
dev.off()

# Draw the plot
with(toplot , vioplot( 
  estimate[model=="GBM"] , estimate[model=="RF"], estimate[model=="XGBoost"],  
  col=rgb(0.1,0.4,0.7,0.7) , names=c("GBM","RF","XGBoost") 
))
}