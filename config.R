# first set the path locations
cloudstor_dir <- "~/onedrive/Shared/SURE_STANDARD_STAGING"
# cloudstor_dir <- "C:/Users/287658c/OneDrive - Curtin/Shared/SURE_STANDARD_STAGING"
datadir <- file.path(cloudstor_dir,"Air_pollution_modelling_APMMA/modelling_general/")

# create a sub directory for storing the base model results
if(!file.exists("base_models")) dir.create("base_models")

# create a sub directory for storing the deeper results
if(!file.exists("pred_without_original_vars")) dir.create("pred_without_original_vars")

# create a directory for figures and tables
if(!file.exists("figures_and_tables")) dir.create("figures_and_tables")

# create a folder for these GeoTIF results
results_label <- paste0("results_",run_label)
if(!file.exists(results_label)) dir.create(results_label)

