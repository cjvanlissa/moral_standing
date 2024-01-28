eval_results <- function(dat, res_lasso, res_ranger){
# Evaluate performance ----------------------------------------------------
mean_y_train <-  mean(dat$train$moral_concern)

# On training data
  X <- model.matrix(moral_concern ~., dat$train)[, -1]
  tss <- sum((dat$train$moral_concern - mean_y_train) ^ 2)
# Lasso
  pred_lasso <- (X %*% res_lasso$coef)[,1, drop = TRUE]
  rss <- sum((pred_lasso - dat$train$moral_concern) ^ 2)

  rsq_lasso <- 1 - rss/tss

# Ranger

rss <- sum((mlr:::predict.WrappedModel(res_ranger$model, newdata = dat$train)$data$response - dat$train$moral_concern) ^ 2)
rsq_ranger <- 1 - rss/tss

# On test data
X <- model.matrix(moral_concern ~., dat$test)[, -1]
tss <- sum((dat$test$moral_concern - mean_y_train) ^ 2)

# Lasso
pred_lasso <- (X %*% res_lasso$coef)[,1, drop = TRUE]
rss <- sum((pred_lasso - dat$test$moral_concern) ^ 2)

rsq_lasso_test <- 1 - rss/tss

# Ranger
rss <- sum((mlr:::predict.WrappedModel(res_ranger$model, newdata = dat$test)$data$response - dat$test$moral_concern) ^ 2)
tss <- sum((dat$test$moral_concern - mean_y_train) ^ 2)
rsq_ranger_test <- 1 - rss/tss

data.frame(
    R2 = c(rsq_lasso, rsq_ranger, rsq_lasso_test, rsq_ranger_test),
    model = rep(c("lasso", "ranger"), 2),
    data = rep(c("train", "test"), each = 2)
  )
}
