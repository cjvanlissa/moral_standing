# Tree
do_tree <- function(dat){
  library(rpart)
  X <- model.matrix(moral_concern ~., dat$train)[, -1]
  Y <- as.numeric(dat$train$moral_concern)
  tune_grid <- expand.grid(
    minbucket = as.integer(seq(2, nrow(dat$train)/100, length.out = 20))
  )

  res_tune <- sapply(1:nrow(tune_grid), function(i){
    pred_cv <- unlist(lapply(dat$folds, function(f){
      Args <- list(
        formula = quote(moral_concern ~ .),
        data = dat$train[-f, ],
        method = "anova",
        control = do.call(rpart.control, args = as.list(tune_grid[i, , drop = F]))
      )
      tree_model <- do.call(rpart, args = Args)
      predict(tree_model, newdata = dat$train[f, ])
    }))
    pred_cv <- pred_cv[unlist(dat$folds)]
    mean((dat$train$moral_concern - pred_cv)^2)
  })

  Args <- list(
    formula = quote(moral_concern ~ .),
    data = dat$train,
    method = "anova",
    control = do.call(rpart.control, args = as.list(tune_grid[which.min(res_tune), , drop = F]))
  )
  tree_model <- do.call(rpart, args = Args)

  pred <- predict(tree_model, newdata = dat$test)
  pred_train <- predict(tree_model, newdata = dat$train)

  out <- list(
    res_cv = res_tune,
    res = tree_model,
    tune_pars = as.vector(tune_grid[which.min(res_tune), , drop = FALSE]),
    rsq = rsq(dat$test$moral_concern, pred, mean(dat$train$moral_concern))
    , rsq_train = rsq(dat$train$moral_concern, pred_train, mean(dat$train$moral_concern))
  )
  class(out) <- "res_tree"
  return(out)
}
