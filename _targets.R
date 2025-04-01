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
    name = features,
    command = list(
      all = setdiff(names(dat$train), "moral_concern")
    , target = c("sentience", "agency", "soc_cog", "harmfulness", "target_group", "utility", "similarity_humans")
    , judge = c("mf_fairness", "mf_authority", "mf_loyalty", "mf_sanctity", "trust", "anomie_social_fabric")
    , demographic = c("gender", "age", "country", "social_status", "conservative_econ", "conservative_social")
    )
  )
  , tar_target(
    name = dat_features,
    command = select_features(dat, features)
  )
  , tar_target(
    name = res_lasso,
    command = lapply(dat_features, do_lasso)
  )
  , tar_target(
    name = res_ranger,
    command = lapply(dat_features, do_ranger)
  )
  , tar_target(
    name = res_tree,
    command = lapply(dat_features, do_tree)
  )
  , tar_target(
    name = res_nn,
    command = do_nn(dat_features)
  )
  , tar_target(
    name = analysis_results,
    command = eval_results(dat, models = list(lasso = res_lasso, ranger = res_ranger, tree = res_tree))
  )
  # , tarchetypes::tar_render(manuscript, "manuscript.rmd", cue = tar_cue("always"))
  # , tar_file (
  #   name = create_index,
  #   command = { file.copy("manuscript.html", "index.html"); return("index.html")}
  #   )
)
