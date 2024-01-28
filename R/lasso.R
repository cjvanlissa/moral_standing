# LASSO
do_lasso <- function(dat){
  X <- model.matrix(moral_concern ~., dat$train)[, -1]
  Y <- as.numeric(dat$train$moral_concern)
  dat$folds
  dat$train_id
  #all.folds <- lars:::cv.folds(length(dat$train$moral_concern), 10)
  all.folds <- dat$folds

  res_lasso <- lars::cv.lars(x = X,
                       y = Y,
                       K = all.folds)


  idx <- which.max(res_lasso$cv - res_lasso$cv.error <= min(res_lasso$cv))
  coefs <- coef(lars::lars(X, Y))[idx,]
  return(
    list(
      res = res_lasso,
      coef = coefs # Use x %*% coef to get predicted values
    )
  )
}
