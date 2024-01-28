do_ranger <- function(dat){
  library(mlr)
  library(tuneRanger)
  library(ranger)
  reg_task = mlr::makeRegrTask(data = dat$train, target = "moral_concern", blocking = factor(dat$train_id))
  # Tuning
  res_tune_ranger = tuneRanger::tuneRanger(reg_task, measure = list(mse))
  return(
    res_tune_ranger
  )
}
