# do_load_the_data_from_Nico 
load(file.path(datadir, '/data_o3_ppb_1hr_max.RData'))
# as given from Nico’s code this includes: 
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
# # as given from Nico’s code
dim(test_o3_ppb_1hr_max)
# 735  194
test_o3_ppb_1hr_max <- dplyr::left_join(test_o3_ppb_1hr_max, 
                                        data_o3_ppb_1hr_max_with_wthr_maxtmp_mly_avg, 
                                        by = c("gid", "year", "month"))

#' 


# ## OLD output
# data_from_Nico <- list()
# data_from_Nico["data_o3_ppb_1hr_max"] <- data_o3_ppb_1hr_max
# data_from_Nico["train_o3_ppb_1hr_max"] <- train_o3_ppb_1hr_max
# data_from_Nico["test_o3_ppb_1hr_max"] <- test_o3_ppb_1hr_max
# return(data_from_Nico)
# }

# NB it is crucial that the row order has not changed because we use a list for nonspatial CV
# 'merge()' can return a data.frame with a new order
# we can check this by listing the monitors identified within each of the validRows sets

# for(i in 1:10){
#   qc <- train_o3_ppb_1hr_max[validRows_o3_ppb_1hr_max[[i]],]
#   cat(paste0("\n\n\n",i," -----------------\n\n\n"))
#   print(data.frame(table(qc$gid)))
# }
'
1 -----------------


                Var1 Freq
1          civic_ACT   60
2  geelong_south_VIC  148
3 macquarie_park_NSW   16
4 mountain_creek_QLD  137
5      warrawong_NSW   15



2 -----------------


                                  Var1 Freq
1                         box_hill_VIC  103
2                           camden_NSW   69
3                           florey_ACT   49
4 northern_adelaide_elizabeth_downs_SA  149
5                         prospect_NSW  124
6                        traralgon_VIC  136
7                         wallsend_NSW  149



3 -----------------


                                    Var1 Freq
1                  albion_park_south_NSW  138
2                           earlwood_NSW  147
3 eastern_adelaide_kensington_gardens_SA  145
4                        mooroolbark_VIC  137
5                           pinkenba_QLD   88
6                           randwick_NSW  150



4 -----------------


                        Var1 Freq
1             beresfield_NSW  148
2          flinders_view_QLD  141
3       parramatta_north_NSW   15
4             springwood_QLD  123
5 western_adelaide_netley_SA  143



5 -----------------


                                  Var1 Freq
1                        dandenong_VIC  134
2                        footscray_VIC  136
3                    kembla_grange_NSW  145
4 north_eastern_adelaide_northfield_SA  156
5                       point_cook_VIC  135
6                          rozelle_NSW  151
7                       wollongong_NSW  151



6 -----------------


               Var1 Freq
1       arundel_QLD   14
2     bringelly_NSW  144
3        monash_ACT   54
4 morwell_south_VIC   52
5    mutdapilly_QLD  143
6      st_marys_NSW  145
7      vineyard_NSW  128



7 -----------------


             Var1 Freq
1 cannon_hill_QLD   16
2      melton_VIC  130
3     oakdale_NSW  151
4    richmond_NSW  156
5     rocklea_QLD  121



8 -----------------


                 Var1 Freq
1      alphington_VIC  141
2           bargo_NSW  154
3   deception_bay_QLD  139
4       newcastle_NSW  142
5 north_toowoomba_QLD   52
6            rmit_VIC   20



9 -----------------


                                  Var1 Freq
1                     altona_north_VIC  100
2                         brighton_VIC  112
3                        lindfield_NSW  123
4                        liverpool_NSW  149
5 north_western_adelaide_le_fevre_2_SA   41
6                            wyong_NSW   60



10 -----------------


                                 Var1 Freq
1               campbelltown_west_NSW   70
2                        chullora_NSW  156
3                        hopeland_QLD   30
4                       macarthur_NSW   83
5                   north_maclean_QLD  140
6 southern_adelaide_christie_downs_SA  129
'

