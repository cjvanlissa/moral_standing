# LASSO
do_lasso <- function(dat){
  X <- model.matrix(moral_concern ~., dat$train)[, -1]
  Y <- as.numeric(dat$train$moral_concern)
  #all.folds <- lars:::cv.folds(length(dat$train$moral_concern), 10)
  all.folds <- dat$folds

  res_lasso <- lars::cv.lars(x = X,
                       y = Y,
                       K = all.folds)


  idx <- which.max(res_lasso$cv - res_lasso$cv.error <= min(res_lasso$cv))

  res_lars <- lars::lars(X, Y)
  pred <- predict(res_lars, newx = model.matrix(moral_concern ~., dat$test)[, -1], s = idx)
  pred_train <- predict(res_lars, newx = model.matrix(moral_concern ~., dat$train)[, -1], s = idx)

  out <- list(
    res_cv = res_lasso,
    res = res_lars,
    tune_pars = c("lambda1sd" = res_lasso$index[idx]),
    rsq = rsq(dat$test$moral_concern, pred$fit, mean(dat$train$moral_concern))
    , rsq_train = rsq(dat$train$moral_concern, pred_train$fit, mean(dat$train$moral_concern))
  )
  class(out) <- "res_lasso"
  return(out)
}
