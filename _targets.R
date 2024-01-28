# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.
library(worcs)
library(lme4)
library(tuneRanger)
library(ranger)
library(glmnet)
library(tuneRanger)
library(mlr)
library(doParallel)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.
set.seed(812)
# Replace the target list below with your own:
list(
  tar_target(
    name = df,
    command = get_data()
    )
  , tar_target(
    name = dat,
    command = split_train_test(df, k = 10)
  )
  , tar_target(
    name = res_lasso,
    command = do_lasso(dat)
  )
  , tar_target(
    name = res_ranger,
    command = do_ranger(dat)
  )
  , tar_target(
    name = fit_table,
    command = eval_results(dat, res_lasso, res_ranger)
  )
  # , tarchetypes::tar_render(manuscript, "manuscript/manuscript.rmd")
)
