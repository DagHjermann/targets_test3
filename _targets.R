# _targets.R file:

library(targets)
library(tarchetypes)
library(tibble)

source("functions.R")

tar_option_set(packages = c("readr", "dplyr", "ggplot2"))

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

#
# example 3 ----
#
# As example 2, but using separate files for each month
# Works, and when one month is changed, only that branch is invalidated
# So, does save any time when only some data are changed

targets <- tar_map(
  list(month = 5:9),
  tar_target(filename, paste0("data_ex3/data_", month, ".csv")),
  tar_target(file, filename, format = "file"),
  tar_target(data, get_data_ex3(file)),
  tar_target(model, fit_model(data)),
  tar_target(plot, plot_model(model, data))
)
list(targets)
