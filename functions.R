# R/functions.R

# For example 2
get_data_ex2 <- function(file, month = 5) {
  read_csv(file, col_types = cols()) %>%
    filter(Month %in% month)
}

# For example 3
get_data_ex3 <- function(file) {
  read_csv(file, col_types = cols())
}

# For example 2 and 3
fit_model <- function(data) {
  lm(Wind ~ Temp, data) %>%
    coefficients()
}

# For example 2 and 3
plot_model <- function(model, data) {
  ggplot(data) +
    geom_point(aes(x = Wind, y = Temp)) +
    geom_abline(intercept = model[1], slope = model[2])
}