# do_load_the_data_from_source 
load(file.path(datadir, '/data_o3_ppb_1hr_max.RData'))
# as given from source code this includes: 
# "data_o3_ppb_1hr_max", 
# "test_o3_ppb_1hr_max", 
# "train_o3_ppb_1hr_max",  
# "validRows_o3_ppb_1hr_max" # NOTE "validRows_o3_ppb_1hr_max" which identifies the 10 folds spatial CV

# now add the wthr_maxtmp_mly_avg data that was left off initially (new data added by ivan)
data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg <- readRDS(paste0(datadir, 
                                                               '/data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg.rds'))
dim(data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg)
# 10080     4
summary(data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg)
data.frame(table(data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg$gid))
# this is a complete data frame with observed max tmp in each year x month (168)

# now attach these to the o3 data for modelling
dim(data_o3_ppb_1hr_max)
# 7368  194
data_o3_ppb_1hr_max <- dplyr::left_join(data_o3_ppb_1hr_max, 
                                        data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg, 
                                        by = c("gid", "year", "month"))
dim(data_o3_ppb_1hr_max)
# 7368  195
data.frame(table(data_o3_ppb_1hr_max$gid))
# 

# now do the same for the training data
dim(train_o3_ppb_1hr_max)
# 6633  194
train_o3_ppb_1hr_max <- dplyr::left_join(train_o3_ppb_1hr_max, 
                                         data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg, 
                                         by = c("gid", "year", "month"))
dim(train_o3_ppb_1hr_max)

# and do the merge for the test data
# # as given from source’s code
dim(test_o3_ppb_1hr_max)
# 735  194
test_o3_ppb_1hr_max <- dplyr::left_join(test_o3_ppb_1hr_max, 
                                        data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg, 
                                        by = c("gid", "year", "month"))

