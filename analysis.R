library(worcs)
library(lme4)
library(tuneRanger)
library(ranger)
library(glmnet)
library(tuneRanger)
library(mlr)
library(doParallel)
run_everything <- FALSE

load_data()
class(df_anal) <- "data.frame"
# df_anal <- df_anal[df_anal$id %in% sample(unique(df_anal$id), 100), ]

# Split the data into train and test data sets ----------------------------
n <- length(unique(df_anal$id))
set.seed(812)
train <- sample(unique(df_anal$id), size = floor(.7*n))

df_train <- df_anal[df_anal$id %in% train, ]
train_id <- df_train$id
df_test <- df_anal[!df_anal$id %in% train, ]
test_id <- df_test$id
df_train[["id"]] <- NULL
df_test[["id"]] <- NULL

# Create k-folds ----------------------------------------------------------

k <- 10
set.seed(9953)
fold <- sample.int(k, replace = TRUE, size = length(unique(train_id)))




# Run analyses ------------------------------------------------------------

# LASSO

X <- model.matrix(moral_concern ~., df_train)[, -1]
if(run_everything){
  registerDoParallel(7)
  res_lasso <- cv.glmnet(
    x = X,
    y = df_train$moral_concern,
    type.measure = "mse",
    nfolds = 10,
    foldid = train_id,
    parallel = TRUE
  )
  saveRDS(res_lasso, "res_lasso.rdata")
} else {
  res_lasso <- readRDS("res_lasso.rdata")
}
lambda <- res_lasso$lambda.1se
res_lasso_best <- glmnet(X, df_train$moral_concern, lambda = lambda)

# Ranger
if(run_everything){
  reg_task = makeRegrTask(data = df_train, target = "moral_concern", blocking = factor(train_id))
  # Tuning
  res_tune_ranger = tuneRanger(reg_task, measure = list(mse))
  saveRDS(res_tune_ranger, "res_tune_ranger.rdata")
} else {
  res_tune_ranger <- readRDS("res_tune_ranger.rdata")
}

# Evaluate performance ----------------------------------------------------

# On training data
# Lasso
rss <- sum((predict(res_lasso_best, s = lambda, newx = X) - df_train$moral_concern) ^ 2)
tss <- sum((df_train$moral_concern - mean(df_train$moral_concern)) ^ 2)
rsq_lasso <- 1 - rss/tss

# Ranger
rss <- sum((predict(res$model, newdata = df_train)$data$response - df_train$moral_concern) ^ 2)
tss <- sum((df_train$moral_concern - mean(df_train$moral_concern)) ^ 2)
rsq_ranger <- 1 - rss/tss

# On test data
# Lasso
X_test <- model.matrix(moral_concern ~., df_test)[, -1]
rss <- sum((predict(res_lasso_best, s = lambda, newx = X_test) - df_test$moral_concern) ^ 2)
tss <- sum((df_test$moral_concern - mean(df_train$moral_concern)) ^ 2)
rsq_lasso_test <- 1 - rss/tss

# Ranger
rss <- sum((predict(res$model, newdata = df_test)$data$response - df_test$moral_concern) ^ 2)
tss <- sum((df_test$moral_concern - mean(df_train$moral_concern)) ^ 2)
rsq_ranger_test <- 1 - rss/tss

