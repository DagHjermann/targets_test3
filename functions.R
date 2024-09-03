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

# For example 8
fit_model2 <- function(data) {
  lm(Wind ~ Temp, data)
}

# For example 2 and 3
plot_model <- function(model, data) {
  ggplot(data) +
    geom_point(aes(x =  Temp, y = Wind)) +
    geom_abline(intercept = model[1], slope = model[2])
}

# For example 4
split_by_month <- function(data){
  split(data, data$Month)
}

# For example 7
some_QC_process <- function(data){
  # just for testing, the QC simply removes month 6
  subset(data, Month != 6)
}

# For example 7
fit_model_safe <- function(data) {
  if (!is.null(data)){
    lm(Wind ~ Temp, data) %>%
      coefficients()
  } else {
    NULL
  }
}
plot_model_safe <- function(model, data) {
  if (!is.null(data)){
    gg <- ggplot(data) +
      geom_point(aes(x =  Temp, y = Wind)) +
      geom_abline(intercept = model[1], slope = model[2])
  } else {
    NULL
  }
}

