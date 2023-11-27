#do_predictors_and_responce <- function(data_from_Nico){

#set the predictor monthly "o3" and dependence variables
colnames(train_o3_ppb_1hr_max)[c(1,10,11)]
predictor <- colnames(train_o3_ppb_1hr_max)[-c(1,10,11)]

# do not include O3 and NO2 
# do not include gid

dependence <- c("o3_ppb_1hr_max")

# create train and test dataset with variables we need
train_o3_ppb_1hr_max_caret <- dplyr::select(train_o3_ppb_1hr_max,
                                            all_of(predictor),
                                            all_of(dependence))

test_o3_ppb_1hr_max_caret <- dplyr::select(test_o3_ppb_1hr_max,
                                           all_of(predictor),
                                           all_of(dependence))

## output

#}