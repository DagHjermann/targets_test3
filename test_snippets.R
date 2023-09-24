
#
# Libraries and functions ----
#

# Libraries
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
dir.create("data_ex3")
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
# Example 3 - modify data ----
#

# Modify data -delete half of the measurements in June
nrow(airquality_split[["6"]])
airquality_june_mod <- dplyr::sample_n(airquality_split[["6"]], 10)
nrow(airquality_june_mod)
write.csv(airquality_june_mod, "data_ex3/data_6.csv", quote = FALSE, row.names = FALSE)

tar_visnetwork()  # show pipeline again - only June is invalidated, as intended!  
tar_make()        # runs everything again  
tar_read(plot_6)  # this has only 10 points (as it should)

# Works as intended!




