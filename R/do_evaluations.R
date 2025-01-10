# explore the spatiotemporal pattern of the deeper estimates

#### functions ####
library(raster)
#library(rgdal)
#library(mgcv)
#library(fields)
#library(maptools)
#library(oz)
library(data.table)
library(animation)
ani.options('autobrowse' = FALSE, verbose = FALSE)


#### load ####
#cloudstor_dir <- "c:/Users/ivan_hanigan/cloudstor/Shared/ResearchProjects_CAR"
#datadir <- file.path(cloudstor_dir,"Air_pollution_modelling_APMMA/modelling_general/")

#setwd(paste0(cloudstor_dir))
load(file.path(datadir, '/data_o3_ppb_1hr_max.RData'))
#### predictors and responce ####
#set the predictor monthly "o3" and dependence variables
predictor <- colnames(train_o3_ppb_1hr_max)[-c(1,10,11)]

# do not include NO2 due to the missing value
# do not include gid

dependence <- c("o3_ppb_1hr_max")

# create train and test dataset with variables we need
#train_o3_ppb_1hr_max_caret <- dplyr::select(train_o3_ppb_1hr_max,predictor,dependence)
names(test_o3_ppb_1hr_max)
#test_o3_ppb_1hr_max_caret <- dplyr::select(test_o3_ppb_1hr_max,predictor,dependence)


# dir(datadir)
dt_v1 <- fread(file.path(dirname(datadir),
                         "GIS_predictors_from_CARDAT/data_derived_for_modelling",
                         "apmma_mly_o3_no2_data_2005_2018_V20210527_no_missing_spatiotemporal_for_modelling.csv")
               )
# dim(dt_v1)























dt_v1[,1:10]
head(data_o3_ppb_1hr_max[,1:10])
head(test_o3_ppb_1hr_max[,1:10])
head(train_o3_ppb_1hr_max[,1:10])

analyte <- data_o3_ppb_1hr_max[,c(c("gid", "state","lon_metres","lat_metres", "year", "month", "o3_ppb_1hr_max"))] #dt_v1#[state == "SA"]
head(analyte)
analyte$x <- analyte$lon_metres
analyte$y <- analyte$lat_metres
analyte$date_i <- as.Date(paste(analyte$year, analyte$month, 1, sep = "-"))
test_df <- test_o3_ppb_1hr_max[,c(c("gid", "year", "month", "o3_ppb_1hr_max"))]
test_df$o3_test <- test_df$o3_ppb_1hr_max
analyte <- merge(analyte, test_df, all.x = T, by = c("gid", "year", "month", "o3_ppb_1hr_max"))
head(analyte)
train_df <- train_o3_ppb_1hr_max[,c(c("gid", "year", "month", "o3_ppb_1hr_max"))]
train_df$o3_train <- train_df$o3_ppb_1hr_max
analyte <- merge(analyte, train_df, all.x = T, by = c("gid", "year", "month", "o3_ppb_1hr_max"))
head(analyte)
analyte0 <- analyte
dir()

dir(paste0("results_", run_label))
# old prior alven scatter results_o3_20211004")
# old with raw results_o3_20210927
# OLD with constrained results_o3_20210915")
#### deeper anim ####

indir_deep <- paste0("results_", run_label)


  #"Air_pollution_modelling_APMMA/modelling_DEEPER/o3_monthly/results_o3_20211004"
# old with raw results_o3_20210927
# OLD with constrained results_o3_20210915"
dir(indir_deep)
timestodo <- dir(indir_deep, recursive = T, full.names = T, pattern = ".tif$")
timestodo <- timestodo[grep("deeper", timestodo)]
basename(timestodo)

outdir <- paste0("results_",run_label,"_animation")
# old "results_o3_20211004_animation")
# old raw results_o3_20210927_animation
# OLD constrained "results_o3_20210915_animation")
dir.create(outdir)
projdir <- getwd()
setwd(outdir)
#### get predictions ####

for(i in 1:length(timestodo)){
  # i = 1
  
  idx<-as.Date(
    paste(strsplit(basename(timestodo[i]), "_")[[1]][4],
          gsub(".tif","",strsplit(basename(timestodo[i]), "_")[[1]][5]),
          1, sep = "-")
  )
  
  r <- raster(file.path("../", timestodo[i]))
  #t_todo <- gsub("o3_","",gsub(".tif","", basename(timestodo[i])))
  t_todo <- idx #as.Date(paste(strsplit(t_todo, "_")[[1]][1],strsplit(t_todo, "_")[[1]][2],1,sep="-")) 
  
  #  analyte[analyte$t==timestodo[i],"date_i"][1])
  analyte_todo <- analyte[analyte$date_i==t_todo & (analyte$state == "NSW" | analyte$state == "ACT"),]
  sp <- SpatialPointsDataFrame(cbind(
    analyte_todo$x,
    analyte_todo$y), 
    analyte_todo[,c("gid", "state", "year", "month", "o3_train", "o3_test")]
  )
  #summary(sp@data)
  e <- raster::extract(r, sp)
  #str(e)
  out <- cbind(sp@data, idx, e)
  #head(out)
  if(i == 1){
    dat_out <- out
  } else {
    dat_out <- rbind(dat_out, out)
  }
}
summary(dat_out)
table(dat_out$year)
with(dat_out, plot(e, o3_train))
with(dat_out, points(e, o3_test, col = 'red', pch = 16))
abline(0,1)

analyte <- analyte0
analyte <- merge(analyte, dat_out, all.x = T, by = c("gid", "state","year", "month", "o3_train", "o3_test"))
analyte$idx <- NULL
head(analyte)

caret::R2(pred = analyte$e, obs = analyte$o3_test, na.rm=T)
caret::RMSE(pred = analyte$e, obs = analyte$o3_test, na.rm=T)

caret::R2(pred = analyte$e, obs = analyte$o3_train, na.rm=T)
caret::RMSE(pred = analyte$e, obs = analyte$o3_train, na.rm=T)

#### do ani loop spt ####
#saveGIF(
saveHTML(
  
  for(i in 1:length(timestodo)){
    # i = 1
    par(mar=c(2,2,1,1))
    m <- matrix(c(rep(1,6),2:9),2,7)
    layout(m)
    #layout.show(9)
    ## map
    #    spg <- gr3[gr3$times==timestodo[i],c("x", "y", "pred$fit")]
    #    dim(spg)
    #spg
    #    names(spg) <- c("x", "y", "z")
    #spg$z <- ifelse(spg$z <0,0,spg$z)
    #    coordinates(spg) <- ~ x + y
    #    gridded(spg) <- TRUE
    #    r <- raster(spg)
    
    idx<-as.Date(
      paste(strsplit(basename(timestodo[i]), "_")[[1]][4],
            gsub(".tif","",strsplit(basename(timestodo[i]), "_")[[1]][5]),
            1, sep = "-")
    )
    print(idx)
    
    
    r <- raster(file.path("../",timestodo[i]))
    
    #writeRaster(r, "o3_2005_qc.tif", overwrite = T)
    # 
    #plot(sp_full, pch = '', cex = 0.05, xlim=c(min(analyte$x), (max(analyte$x) + 150000)))
    #plot(r, col = tim.colors(32), zlim=c(0,26), add = T)
    imagePlot(r, 
              xlim=c(min(analyte$x) - 5000, (max(analyte$x) + 25000)),
              ylim=c(min(analyte$y) - 5000, (max(analyte$y) + 5000)),
              zlim = c(0,65), legend.only = F, graphics.reset = F
    )
    
    #plot(shp, add = T)
    #t_todo <- gsub("o3_monthly_","",gsub("_spacetime_nonlinear.tif","", basename(timestodo[i])))
    #t_todo <- as.Date(paste(strsplit(t_todo, "_")[[1]][1],strsplit(t_todo, "_")[[1]][2],1,sep="-")) 
    #
    #  analyte[analyte$t==timestodo[i],"date_i"][1])
    sp <- SpatialPointsDataFrame(cbind(
      analyte$x[analyte$date_i==idx],
      analyte$y[analyte$date_i==idx]), 
      analyte[analyte$date_i==idx,]
    )
    # write.csv(sp@data, "foo.csv", row.names = F)
    
    #plot(sp, add=T)
    #text(sp, round(sp@data$o3_ppb_1hr_max,0), cex = 0.95)
    # if(nrow(test[test$t==timestodo[i],])>0){
    #   sp_test <- SpatialPointsDataFrame(cbind(test$x[test$t==timestodo[i]],
    #                                           test$y[test$t==timestodo[i]]), 
    #                                     test[test$t==timestodo[i],]
    #   )
    #   
    #   plot(sp_test, add=T, pch = "*")
    #   text(sp_test, sp_test@data$gid, cex = 0.75)
    #}
    #box()
    #axis(1); axis(2)
    title(idx)
    ## monts  
    setDT(analyte)
    stn_list2 <- analyte[!is.na(o3_test) & state == "NSW",.N,by=.(gid)]
    stn_list2 <- stn_list2[rev(order(N))]$gid
    for(j in 1:2){plot(1,1, type = "n", axes=F)}
    for(j in 1:4){#length(unique(analyte$gid))){#nrow(stn_list2)){
      # j = 1
      stn_i2 <- j
      
      
      # head(test_full)
      #setDT(analyte)
      with(analyte[analyte$gid %in% stn_list2[stn_i2],],
           plot(as.Date(date_i),o3_train,type="b", pch = 16, cex = 0.8,
                main=stn_list2[stn_i2],
                ylab="o3", ylim=c(0,60),
                xlim = c(as.Date(paste(2005,1,1,sep="-")),
                         as.Date(paste(2006,12,31,sep="-")))
                
           )
      )
      with(analyte[analyte$gid %in% stn_list2[stn_i2],], points(as.Date(date_i), o3_test, col = 'red'))
      segments(idx,
               0,
               idx,
               80,col='red')      
      
      #ylim=c(0,60),
      if(!all(is.na((dat_out[dat_out$gid %in% stn_list2[stn_i2],"e"])))){
        # with(dat_out[dat_out$gid %in% stn_list2[stn_i2],],
        #      plot(as.Date(idx),e,type="b", pch = 16, cex = 0.8,
        #           main=stn_list2[stn_i2],
        #           ylab="o3", col = "blue",
        #           xlim = c(as.Date(paste(2005,1,1,sep="-")),
        #                    as.Date(paste(2019,12,31,sep="-")))
        #           
        #      )
        # )
        with(dat_out[dat_out$gid %in% stn_list2[stn_i2],],
             lines(as.Date(idx),e,type="l", col = "blue")
        ) 
        abline(0,0)
      } else {
        plot(1,1, type = "n")
      }
      #with(test_full[test_full$gid %in% stn_list2[stn_i2],],
      #     lines(date_i,pred,col='blue'))
      #setDF(analytepred)
      #
      segments(idx,
               0,
               idx,
               100,col='red')
      #dev.off()
    }
    for(j in 1:3){plot(1,1, type = "n", axes=F)}
    strt <- 4
    for(j in 1:4){#length(unique(analyte$gid))){#nrow(stn_list2)){
      # j = 1
      stn_i2 <- strt+1
      
      
      # head(test_full)
      setDT(analyte)
      with(analyte[analyte$gid %in% stn_list2[stn_i2],],
           plot(as.Date(date_i),o3_train,type="b", pch = 16, cex = 0.8,
                main=stn_list2[stn_i2],
                ylab="o3", ylim=c(0,60),
                xlim = c(as.Date(paste(2005,1,1,sep="-")),
                         as.Date(paste(2006,12,31,sep="-")))
                
           )
      )
      with(analyte[analyte$gid %in% stn_list2[stn_i2],], points(as.Date(date_i), o3_test, col = 'red'))
      segments(idx,
               0,
               idx,
               80,col='red')      
      
      #ylim=c(0,60),
      #      if(!all(is.na((dat_out[dat_out$gid %in% stn_list2[stn_i2],"e"])))){
      # with(dat_out[dat_out$gid %in% stn_list2[stn_i2],],
      #      plot(as.Date(idx),e,type="b", pch = 16, cex = 0.8,
      #           main=stn_list2[stn_i2],
      #           ylab="o3", col = "blue",
      #           xlim = c(as.Date(paste(2005,1,1,sep="-")),
      #                    as.Date(paste(2019,12,31,sep="-")))
      #           
      #      )
      # )
      with(dat_out[dat_out$gid %in% stn_list2[stn_i2],],
           lines(as.Date(idx),e,type="l", col = "blue")
      ) 
      abline(0,0)
      # } else {
      #   plot(1,1, type = "n")
      # }
      #with(test_full[test_full$gid %in% stn_list2[stn_i2],],
      #     lines(date_i,pred,col='blue'))
      #setDF(analytepred)
      #
      segments(idx,
               0,
               idx,
               100,col='red')
      #dev.off()
      strt <- strt+j
    }
    # with(outdat_bme, plot(date_i, e, type = "l", ylim = c(0,17), lwd = 2, ylab = 'o3 (ppb)', xlab = "Months"))
    # segments(t_todo,
    #          0,
    #          t_todo,
    #          80,col='red')
    # title("BME avg")
  }      
  , interval = 1, outdir = getwd(),movie.name = "spacetimegam_movie.html", ani.dev = function(...){png(res=75*1.1,...)}, ani.width = 1000, ani.height = 500
)	

getwd()
setwd(projdir)

names(analyte)
head(analyte[analyte$gid == "st_marys_NSW", c("gid", "date_i", "o3_ppb_1hr_max", "o3_train", "o3_test", "e")],48)
head(analyte[analyte$gid == "civic_ACT", c("gid", "date_i", "o3_ppb_1hr_max", "o3_train", "o3_test", "e")],48)

#?caret::R2
caret::R2(pred=analyte$e, obs = analyte$o3_test, na.rm = T)

summary(lm(o3_test ~ e, data = analyte))

caret::RMSE(pred=analyte$e, obs = analyte$o3_test, na.rm = T)

caret::R2(pred=analyte$e, obs = analyte$o3_train, na.rm = T)

caret::RMSE(pred=analyte$e, obs = analyte$o3_train, na.rm = T)


# save output
analyte$pred_deeper <- analyte$e
analyte$e <- NULL
head(analyte)
write.csv(analyte, paste0("results_",run_label,"_animation/results_deeper_",run_label,".csv"), row.names = F)
