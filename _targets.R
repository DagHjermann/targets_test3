# _targets.R file:

library(targets)
library(tarchetypes)
library(tibble)

source("functions.R")

tar_option_set(packages = c("readr", "dplyr", "ggplot2"))

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 1 ----
# - from ?tar_map
#

# targets <- tar_map(
#   list(a = c(12, 34), b = c(45, 78)),
#   targets::tar_target(x, a + b),
#   targets::tar_target(y, x + a, pattern = map(x))
#   )
# list(targets)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 2 ----
#
# "walkthrough" example, adapted using example 1  
# https://books.ropensci.org/targets/walkthrough.html
# 
# Makes one branch per month
# Works!
# But when one month is changed, all branches are run again

# targets <- tar_map(
#   list(month = 5:9),
#   tar_target(file, "data_ex2/data.csv", format = "file"),
#   tar_target(data, get_data_ex2(file, month)),
#   tar_target(model, fit_model(data)),
#   tar_target(plot, plot_model(model, data))
# )
# list(targets)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 3 ----
#
# As example 2, but using separate files for each month
# Works, and when one month is changed, only that branch is invalidated
# So, does save any time when only some data are changed

# targets <- tar_map(
#   list(month = 5:9),
#   tar_target(filename, paste0("data_ex3/data_", month, ".csv")),
#   tar_target(file, filename, format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(model, fit_model(data)),
#   tar_target(plot, plot_model(model, data))
# )
# list(targets)

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 4 ----
#
# As example 3, but reading full file is included 
# Works, but when data of only one month is changed, everything is invalidated
#   and all models and plots are re-run  

# list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(datalist, split_by_month(data)),
#   tar_map(
#     list(month = as.character(5:9)),
#     tar_target(model, fit_model(datalist[[month]])),
#     tar_target(plot, plot_model(model, datalist[[month]]))
#   )
# )

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 5 ----
#
# As example 4 (reading full file is included)
# - but instead of "fit_model" reading "datalist", we first make "data"
# When data of only one month is changed, everything is invalidated,
#   but when tar_make is run, it discovers underway that only data_6 has xchanged,
#   and re-runs only model and plot for this month

# list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(datalist, split_by_month(data)),
#   tar_map(
#     list(month = as.character(5:9)),
#     tar_target(data, datalist[[month]]),      # adding "data" as a target
#     tar_target(model, fit_model(data)),
#     tar_target(plot, plot_model(model, data))
#   )
# )

# . example 5 with error ----
# - for testing error handling  
#
# Error added on purpose (see code below): "list(month = 5:9)" 
# I.e., 'month' is the number 5-9, not the string "5"-"9" as it should be  
# - This will lead to an error because datalist can be referred to as datalist[["5"]] to datalist[["9"]],
#   or datalist[[1]] to datalist[[5]], but not as datalist[[5]]-datalist[[9]]
# - not discovered by tar_manifest
# - not discovered by first run of tar_visnetwork (only shows targets as outdated)  
# - tar_make stops with an error when it comes to month = 6 (as the data list has only 5 months)  
# - when running tar_visnetwork again, it now shows an error for the target data_6  
# Then we correct the error (i.e. use the code above)
# - tar_manifest runs ok  
# - running tar_visnetwork still shows an error! important to know that it does not understand the error has
#   been corrected  
# - tar_make runs ok  
# - running tar_visnetwork again now doesn't shows any error (shows all targets as up to date)  

# list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(datalist, split_by_month(data)),
#   tar_map(
#     list(month = 5:9),    # ERROR: becomes number, not name 
#     tar_target(data, datalist[[month]]),      # adding "data" as a target
#     tar_target(model, fit_model(data)),
#     tar_target(plot, plot_model(model, data))
#   )
# )


#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 6 ----
#
# As example 5
# - but instead of hard-coding "5:9" explicitely, we want it to use the names of 'datalist' 
# Following the approach here:  
#   https://stackoverflow.com/a/72115182
# For more complex problems, see
#   https://github.com/ropensci/tarchetypes/discussions/105 

# # First, read raw data to find the values of Month,
# # and put that in a data frame
# # 'Month' will be used to get the correct list item
# # 'name' will be used to name the targets   
# library(dplyr)
# data_check <- read.csv("data_ex4/airquality.csv")
# params <- data_check %>%
#   distinct(Month) %>%
#   mutate(
#     Month = as.character(Month),
#     name = paste0("mon", Month))
# 
# # Then, give the pipeline as this - note the use of values and 
# # names in 'tar_map'
# list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(datalist, split_by_month(data2)),
#   tar_map(
#     values = params,
#     names = "name",
#     tar_target(data, datalist[[Month]]),      # adding "data" as a target
#     tar_target(model, fit_model(data)),
#     tar_target(plot, plot_model(model, data))
#   )
# )

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 7 ----
#
# As example 6, but we introduce some "QC process", which happens to 
#   delete all the data of one month
# As 'params' has all months included, asking for 'datalist' of the deleted month 
#   will result in NULL
# We must then make new versions of the downstream functions, i.e. 'fit_model_safe'
#   and 'plot_model_safe', which doesn't fall over if 'data' is NULL

data_check <- read.csv("data_ex4/airquality.csv")

# # First, read raw data to find the values of Month,
# # and put that in a data frame
# # 'Month' will be used to get the correct list item
# # 'name' will be used to name the targets   
# library(dplyr)
# params <- data_check %>%
#   distinct(Month) %>%
#   mutate(
#     Month = as.character(Month),
#     name = paste0("mon", Month))
# 
# # Then, give the pipeline as this - note the use of values and 
# # names in 'tar_map'
# list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(data2, some_QC_process(data)),   # 
#   tar_target(datalist, split_by_month(data2)),
#   tar_map(
#     values = params,
#     names = "name",
#     tar_target(data, datalist[[Month]]),      
#     tar_target(model, fit_model_safe(data)),        # safe variant of fit_model
#     tar_target(plot, plot_model_safe(model, data))  # safe variant of plot_model
#   ),
#   tarchetypes::tar_combine(comb, model_mon5, model_mon7)
# )

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 8 ----
#
# As example 6, but we try to combine the "model" data in the end  
# - we drop the plot  
# - the first target list is saved as 'mapped' and used in the 
# second targets list
# - note that tar_manifest shows us whether it does what we want it to do:
# "combined_summaries "dplyr::bind_rows(model_mon5 = model_mon5, model_mon6 = model_mon6,..." 
#
# Based on
# https://github.com/ropensci/targets/discussions/987

# library(dplyr)
# data_check <- read.csv("data_ex4/airquality.csv")
# params <- data_check %>%
#   distinct(Month) %>%
#   mutate(
#     Month = as.character(Month),
#     name = paste0("mon", Month))
# 
# # Then, give the pipeline as this - note the use of values and
# # names in 'tar_map'
# mapped <- list(
#   tar_target(file, "data_ex4/airquality.csv", format = "file"),
#   tar_target(data, get_data_ex3(file)),
#   tar_target(datalist, split_by_month(data)),
#   tar_map(
#     values = params,
#     names = "name",
#     tar_target(data, datalist[[Month]]),      # adding "data" as a target
#     tar_target(model, fit_model(data))
#   )
# )
# list( 
#   mapped,                  # references the first list
#   tar_combine(
#     combined_summaries,
#     mapped[[4]][[2]],      # 'tar_map' is item 4; 'model' is item 2 inside 'tar_map'
#     command = dplyr::bind_rows(!!!.x, .id = "method")
#   ))

#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-
#
# example 9 ----
#
# As example 8, but we use 'fit_model2' which only returns the model object,
#  not the coefficients
# - instead we replace 'bind_rows' with 'summarize_and_combine' which extract 
# coeffecients on the fly

# Remove these objects (only to get a cleaner plot in tar_visnetwork) 
rm(fit_model, plot_model_safe, get_data_ex2, plot_model,
   some_QC_process, fit_model_safe)

library(dplyr)

summarize_and_combine <- function(...){
  model_list <- list(...)
  coeff_list <- purrr::map(model_list, .f = coefficients)
  dplyr::bind_rows(coeff_list)
}

# skip the 'data_check' object - get params directly
params <- read.csv("data_ex4/airquality.csv") %>%
  distinct(Month) %>%
  mutate(
    Month = as.character(Month),
    name = paste0("mon", Month))

rm(data_check)

# Then, give the pipeline as this - note the use of values and
# names in 'tar_map'
mapped <- list(
  tar_target(file, "data_ex4/airquality.csv", format = "file"),
  tar_target(data, get_data_ex3(file)),
  tar_target(datalist, split_by_month(data)),
  tar_map(
    values = params,
    names = "name",
    tar_target(data, datalist[[Month]]),      # adding "data" as a target
    tar_target(model, fit_model2(data))
  )
)
list(
  mapped,
  tar_combine(
    combined_summaries,
    mapped[[4]][[2]],
    command = summarize_and_combine(!!!.x)   # remember: no .id here, as in example 8
  ))





