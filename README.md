# targets_test3

Testing/learning targets, static branching  

- example 1 - simple example from ?tar_map
- example 2 - the "walkthrough" example ([link](https://books.ropensci.org/targets/walkthrough.html)), but adapted using example 1    
    - Data is taken from a text file   
    - Makes one branch per month   
    - Gives the correct reults   
    - But when one month is changed in the data file, all branches are invalidated  
    - Thus all branches (all data) are run again even if only one month's data has been changed  

- example 3 - As example 2, but using separate files for each month
    - When one month's data is changed, only that branch are invalidated  
    - Thus only that branch (on month's data) are run again after the change (as we want!)    
  
Code snippets to make text files and run examples are found in `test_snippets.R`   
NOTE: for a given example, you have to firts uncomment the relevant example in file `_targets.R` (and uncomment all others)


