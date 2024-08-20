
#
# Libraries and functions ----
#

# Libraries
# install.packages("targets")
library(targets)
# library(ggplot2)
# library(tibble)
# library(dplyr)

#
# Example 1 ----
#
# NOTE: you have to uncomment the relevant example in file _targets.R
# (and uncomment all others)

# inspect pipeline
tar_manifest()

# show pipeline  
tar_visnetwork()
tar_visnetwork(targets_only = TRUE)

# run pipeline
tar_make()
tar_visnetwork()  # show pipeline again    

#
# Example 2 ----
#
# NOTE: you have to uncomment the relevant example in file _targets.R
# (and uncomment all others)

# Make data
dir.create("data_ex2")
table(airquality$Month)
# apply(is.na(airquality), 2, sum)
write.csv(airquality, "data_ex2/data.csv", quote = FALSE, row.names = FALSE)

# Note that this example uses *map* in the tar_target
# Also other possibilities, see https://books.ropensci.org/targets/dynamic.html#patterns 

# inspect pipeline
tar_manifest()

# show pipeline  
tar_visnetwork()
tar_visnetwork(targets_only = TRUE)

# run pipeline
tar_make()
tar_visnetwork()  # show pipeline again    

# check intermediate results   
tar_read(file_5)  # same for all months!
tar_read(data_5)

# check results - one plot per month  
tar_read(plot_5)
tar_read(plot_6)
tar_read(plot_7)

#
# Example 2 - modify data ----
#

# Modify data -delete half of the measurements in June
nrow(airquality)
rows <- which(airquality$Month == 6)
rows_to_delete <- sample(rows, 20)
airquality_modified <- airquality[-rows_to_delete, ]
nrow(airquality_modified)
write.csv(airquality_modified, "data_ex2/data.csv", quote = FALSE, row.names = FALSE)

# Does not notice that file 
tar_visnetwork()  # show pipeline again - everything is invalidated  
tar_make()        # runs everything again  
tar_read(plot_6)  # this has only 10 points (as it should)


#
# Example 3 ----
# Read from several files using 'get_data_ex3'  
#

# Make data

# Do this only once:
# dir.create("data_ex3")
airquality_split <- split(airquality,airquality$Month)
# Names given automatically
names(airquality_split)
# File names
fns <- paste0("data_ex3/data_", names(airquality_split), ".csv")
# Write files
purrr::walk2(airquality_split, 
            fns,
            ~write.csv(.x, .y, quote = FALSE, row.names = FALSE)

# Note that this example uses *map* in the tar_target
# Also other possibilities, see https://books.ropensci.org/targets/dynamic.html#patterns 

# inspect pipeline
tar_manifest()

# show pipeline  
tar_visnetwork()
tar_visnetwork(targets_only = TRUE)

# run pipeline
tar_make()
tar_visnetwork()  # show pipeline again    

# check intermediate results   
tar_read(file_5)  # NOT same for all months!
tar_read(data_5)

# check results - one plot per month  
tar_read(plot_5)
tar_read(plot_6)
tar_read(plot_7)

#
# . ex. 3 - run manually ----
# - run without using targets at all, just functions    
#

source("functions.R")
library(readr)
library(dplyr)
library(ggplot2)
# tar_read(file_5)

test_data <- get_data_ex3("data_ex3/data_5.csv")
test_model <- fit_model(test_data)
test_plot <- plot_model(test_model, test_data)
test_plot

#
# . ex. 3 - modify one data file ----
#

# Modify data -delete half of the measurements in June
nrow(airquality_split[["6"]])   # 30

# Modify data by sampling 10 data from the 30 
airquality_june_mod <- dplyr::sample_n(airquality_split[["6"]], 10)
nrow(airquality_june_mod)

# Rewrite file
write.csv(airquality_june_mod, "data_ex3/data_6.csv", quote = FALSE, row.names = FALSE)

tar_visnetwork()  # show pipeline again - only June is invalidated, as intended!  
tar_make()        # runs everything again  
tar_read(plot_6)  # this has only 10 points (as it should)

# Works as intended!

#
# . ex. 3 - modify full data, rewrite all files ----
#
# We modify just one month of the full data,
# but rewrite all files. Will targets understand that all monthly files
# except one doesn't need to be changed?
#

# a. Make original data  
airquality_split <- split(airquality,airquality$Month)
fns <- paste0("data_ex3/data_", names(airquality_split), ".csv")
purrr::walk2(airquality_split, 
             fns,
             ~write.csv(.x, .y, quote = FALSE, row.names = FALSE))

tar_manifest()
tar_make()
tar_visnetwork()  # shows that all targets are up to date  

#
# b. Modify the full data by removal (removing 20 rows from month 6)
#
rows_month <- which(airquality$Month == 6)
rows_month_delete <- sample(rows_month, 20, replace = FALSE)
# modified full file
airquality_mod <- airquality[-rows_month_delete,]
nrow(airquality)
nrow(airquality_mod)
# remake all files
airquality_split <- split(airquality_mod, airquality_mod$Month)
fns <- paste0("data_ex3/data_", names(airquality_split), ".csv")
purrr::walk2(airquality_split, 
             fns,
             ~write.csv(.x, .y, quote = FALSE, row.names = FALSE))

# Success! shows that only month 6 targets are invalidated
tar_visnetwork()
# tar_make skips all unaltered months  
tar_make()
tar_visnetwork()

#
# c. Modify the full data by changing data (changing the wind value of the first day of month 6)
# Note: run part (a) again first  
# 
rows_month <- which(airquality$Month == 6)
rows_modify <- rows_month[1]
# modified full file
airquality_mod <- airquality
airquality_mod$Wind[rows_modify] <- 30  # change this value
# Check value
airquality$Wind[rows_modify]
airquality_mod$Wind[rows_modify]
# remake all files
airquality_split <- split(airquality_mod, airquality_mod$Month)
fns <- paste0("data_ex3/data_", names(airquality_split), ".csv")
purrr::walk2(airquality_split, 
             fns,
             ~write.csv(.x, .y, quote = FALSE, row.names = FALSE))

# Success! shows that only month 6 targets are invalidated
tar_visnetwork()
# tar_make skips all unaltered months  
tar_make()
tar_visnetwork()
tar_read(plot_6)  # this shows one wind outlier (value = 30)



#
# Example 4 - include full data, version 1 ----
# has target "datalist", "model" is using "datalist" directly
#
# We modify just one month of the full data,
# but rewrite all files. Will targets understand that all monthly files
# except one doesn't need to be changed?
#

# dir.create("data_ex4")
write.csv(airquality, "data_ex4/airquality.csv", quote = FALSE, row.names = FALSE)

tar_manifest()
tar_visnetwork()
tar_make()

#
# Modify one number in the data file
#
rows_month <- which(airquality$Month == 6)
rows_modify <- rows_month[1]
# modified full file
airquality_mod <- airquality
airquality_mod$Wind[rows_modify] <- 30  # change this value
write.csv(airquality_mod, "data_ex4/airquality.csv", quote = FALSE, row.names = FALSE)

# This shows all branches are fully invalidated, from data to plot 
tar_visnetwork()
# When running tar_make:
tar_make()
# Everything is recreated, inclulding models and plots for all months
# even though model_5, model_7, model_8 and model_9 could have been skipped:
#
# ▶ dispatched target data_5
# ● completed target data_5 [0 seconds]
# ▶ dispatched target model_6
# ● completed target model_6 [0.01 seconds]
# ▶ dispatched target model_7
# ● completed target model_7 [0.02 seconds]
# etc.


#
# Example 5 - include full data, version 2 ----
# - as ex. 4, but has target "data" betweeen "datalist" and "model"
# - "model" is using "data" 
# When data of only one month is changed, everything is invalidated,
#   but when tar_make is run, it discovers underway that only data_6 has changed,
#   and re-runs only model and plot for this month
#
# This example was also used to show how errors are handled
# - see last part of `_targets.R`  

# dir.create("data_ex4")
write.csv(airquality, "data_ex4/airquality.csv", quote = FALSE, row.names = FALSE)

tar_manifest()
tar_visnetwork()
tar_make()

#
# Modify one number in the data file
#
rows_month <- which(airquality$Month == 6)
rows_modify <- rows_month[1]
# modified full file
airquality_mod <- airquality
airquality_mod$Wind[rows_modify] <- 30  # change this value
write.csv(airquality_mod, "data_ex4/airquality.csv", quote = FALSE, row.names = FALSE)

# This shows all branches are fully invalidated, from data to plot 
tar_visnetwork()
# However, when running tar_make:
tar_make()
# ...it recreates data_6 - data_9, and then only recreates model_6 and plot_6
# model_5, model_7, model_8 and model_9 are skipped! (and same for plots!)
#
# ▶ dispatched target model_6
# ● completed target model_6 [0 seconds]
# ✔ skipped target model_7
# ✔ skipped target model_8
# ✔ skipped target model_9
# ✔ skipped target model_5


#
# Example 6 - avoid hard-coding ----
# - but instead of hard-coding "5:9" explicitely, we want it to use the names of 'datalist' 

# The first idea was to just use the following as 
# first argument of tar_map:
#     list(month = names(datalist))
# But then it stops already in tar_manifest, "cannot find datalist"
# This is due to the metaprogramming tar_map does, see
# ?tar_map and https://github.com/ropensci/tarchetypes/discussions/105
#
# The approach used was the one given here:
# https://stackoverflow.com/a/72115182

tar_manifest()
tar_visnetwork()
tar_make()
tar_read(plot_mon5)

