# LASSO
do_lasso <- function(dat){
  X <- model.matrix(moral_concern ~., dat$train)[, -1]
  Y <- as.numeric(dat$train$moral_concern)
  #all.folds <- lars:::cv.folds(length(dat$train$moral_concern), 10)
  all.folds <- dat$folds
  fold_id <- unlist(lapply(seq_along(all.folds), function(id){
    out <- rep(id, length(all.folds[[id]]))
    names(out) <- all.folds[[id]]
    out
  }))
  fold_id <- fold_id[order(as.integer(names(fold_id)))]
  #an optional vector of values between 1 and nfolds identifying what fold each observation is in. If supplied, nfolds can be missing.

  res_cv <- glmnet::cv.glmnet(X, Y, foldid = fold_id)
  res_lasso <- glmnet::glmnet(X, Y, lambda = res_cv$lambda.1se)

  pred <- predict(res_cv,
                  newx = model.matrix(moral_concern ~., dat$test)[, -1],
                  s = "lambda.1se")
  pred_train <- predict(res_cv,
                        newx = model.matrix(moral_concern ~., dat$train)[, -1],
                        s = "lambda.1se")

  out <- list(
    res_cv = res_cv,
    res = res_lasso,
    tune_pars = c("lambda1sd" = res_cv$lambda.1se),
    rsq = rsq_numeric(dat$test$moral_concern, as.numeric(pred), mean(dat$train$moral_concern))
    , rsq_train = rsq_numeric(dat$train$moral_concern, as.numeric(pred_train), mean(dat$train$moral_concern))
  )
  class(out) <- "res_lasso"
  return(out)
}
