load_packages <- function(pkg = c("SuperLearner",
                                     "caret",
                                     "lubridate",
                                     "ranger",
                                     "gbm",
                                     "xgboost",
                                     "CAST",
                                     "data.table",
                                     "raster",
                                     "glmnet",
                                     "knitr"),
                            do_it = T, force_install = F){

  if(do_it){
    if (force_install){ 
      install.packages(pkg, dependencies = TRUE)
    }
    
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)){ 
      install.packages(new.pkg, dependencies = TRUE)
    }
    
    sapply(pkg, require, character.only = TRUE)
    }
}
