do_ranger <- function(dat){
  library(mlr)
  library(tuneRanger)
  library(ranger)
  reg_task = mlr::makeRegrTask(data = dat$train, target = "moral_concern", blocking = factor(dat$train_id))
  # Tuning
  res_tune_ranger = tuneRanger::tuneRanger(reg_task, measure = list(mse), tune.parameters = c("mtry", "min.node.size"))
  pred <- predict(res_tune_ranger$model$learner.model, data = dat$test)$predictions
  pred_train <- predict(res_tune_ranger$model$learner.model, data = dat$train)$predictions

  out <- list(
    res_cv = res_tune_ranger,
    res = res_tune_ranger$model$learner.model,
    tune_pars = unlist(res_tune_ranger$recommended.pars)[c("mtry", "min.node.size")],
    rsq = rsq(dat$test$moral_concern, pred, mean(dat$train$moral_concern))
    , rsq_train = rsq(dat$train$moral_concern, pred_train, mean(dat$train$moral_concern))
  )
  class(out) <- "res_ranger"
  return(out)
}
