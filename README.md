# targets_test3

Testing/learning targets, static branching.

* Code snippets to make text files and run examples are found in `test_snippets.R`   
* There is only one `_targets.R` file. For a given example, you have to first uncomment the relevant example, and uncomment all others  
* All functions used are in the `functions.R` file  

## Examples  

### example 1 - simple example from ?tar_map  

### example 2 - adapoed "walkthrough" example

* the "walkthrough" example ([link](https://books.ropensci.org/targets/walkthrough.html)), but adapted using example 1:      
    - Data is taken from a text file   
    - Makes one branch per month   
    - Gives the correct results   
    - But when one month is changed in the data file, all branches are invalidated  
    - Thus all branches (all data) are run again even if only one month's data has been changed  

### example 3 - As example 2, but using separate files for each month  
* The separate files are written outside the 'targets' procedure   
    - When one month's data is changed, only that branch are invalidated  
    - Thus only that branch (on month's data) are run again after the change (as we want!)    
    - Moreover, one can also change the full file and rewrite all monthly files, and still unchanged months 
    will not be invalidated (even if they have been rewritten, targets discover that they are not changed)
  
### example 4 - As example 3, but single data file 
* again starting with a single data file  
    - targets reads the file and splits it into a list ('datalist') of data sets (one per month)  
    - When one month's data is changed in the data, all branches are invalidated and all models and plots
    are run again  

### example 5 - As example 4, better version  

* As example 4 (i.e. starting with a single data file), but inserts the target 'data'  
    - in example 4, 'model' is created directly from 'datalist'  
    - in example 4, 'data' (one per month) is created from 'datalist', then 'model' is created from data  
    - when data of only one month is changed, everything is invalidated (using tar_visnetwork),
    but when `tar_make` is run, it discovers underway that only data_6 has changed,
    and re-runs *only* the model and plot for this month  
* example 5 has also been used to get aquinted with how/when errors are shown - see last part of `_targets.R`  


## Some notes  

### Structure of tar_map code  

While an 'ordinary' _targets file contains code such as  
```
list(
  tar_target(...),
  tar_target(...)
)
```
Example:
```
list(
  tar_target(file, "data.csv", format = "file"),
  tar_target(data, get_data(file)),
  tar_target(model, fit_model(data)),
  tar_target(plot, plot_model(model, data))
)
```

`tar_map` goes *inside* the list:
```
list(
  tar_target(...)
  tar_map(
    list(...),
    tar_target(...)
  )
)
```

### Lessons lerned about errors  

* `tar_manifest` may discover errors in `_targets.R` such as lacking comma  
* `tar_make` discovers even more errors (those that only are detected at runtime)  
* `tar_visnetwork` probably does not discover any errors on its own, but 'learns' from `tar_make`    
    - i.e. it shows errors 'discovered' by `tar_make`, but first after `tar_make` has been run     
    - Note: if `tar_make` has resulted in errors and the script has been corrected, `tar_visnetwork` still will show an error! You must run `tar_make` again in order to remove the error from the tar_visnetwork plot  

