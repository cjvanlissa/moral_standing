predict.res_lasso <- function(object, newdata){
  X <- model.matrix(moral_concern ~., newdata)[, -1]
  lars::predict.lars(object$res, s = object$lambda1sd, type = "fit", newx = X)$fit
}
predict.tuneRanger <- function(object, newdata){
  mlr:::predict.WrappedModel(object$model, newdata = newdata)$data$response
}
rsq <- function(model, newdata, tss){
  preds <- predict(model, newdata)
  rss <- sum((preds - newdata$moral_concern) ^ 2)
  return(1 - rss/tss)
}


eval_results <- function(dat, res_lasso, res_ranger){
# Evaluate performance ----------------------------------------------------
mean_y_train <-  mean(dat$train$moral_concern)

# On training data
tss <- sum((dat$train$moral_concern - mean_y_train) ^ 2)
rsq_lasso <- rsq(res_lasso, dat$train, tss)
rsq_ranger <- rsq(res_ranger, dat$train, tss)

# On test data
tss <- sum((dat$test$moral_concern - mean_y_train) ^ 2)
rsq_lasso_test <- rsq(res_lasso, dat$test, tss)
rsq_ranger_test <- rsq(res_ranger, dat$test, tss)

data.frame(
    R2 = c(rsq_lasso, rsq_ranger, rsq_lasso_test, rsq_ranger_test),
    model = rep(c("lasso", "ranger"), 2),
    data = rep(c("train", "test"), each = 2)
  )
}
