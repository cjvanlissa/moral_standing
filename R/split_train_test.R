split_train_test <- function(df, k = 10){
  # Split the data into train and test data sets ----------------------------
  n <- length(unique(df$id))
  train <- sample(unique(df$id), size = floor(.7*n))
  df_train <- df[df$id %in% train, ]
  train_id <- df_train$id
  df_test <- df[!df$id %in% train, ]
  test_id <- df_test$id
  df_train[["id"]] <- NULL
  df_test[["id"]] <- NULL

  # Create k-folds ----------------------------------------------------------
  fold <- split(sample(unique(train_id)), cut(seq_along(unique(train_id)), k, labels=FALSE))
  all.folds <- lapply(1:k, function(i){
    which(train_id %in% fold[[i]])
  })
  names(all.folds) <- 1:k

  # Clean Data
  facs <- names(df_train)[sapply(df_train, inherits, what = "factor")]
  nums <- names(df_train)[sapply(df_train, inherits, what = c("numeric", "integer"))]
  nums <- setdiff(nums, "moral_concern") # Exclude DV
  scld <- scale(df_train[nums], center = TRUE, scale = TRUE)
  means <- attr(scld, "scaled:center")
  sds <- attr(scld, "scaled:scale")
  df_train[nums] <- scld

  scld_test <- df_test[nums]
  scld_test <- sweep(scld_test, 2, means)
  scld_test <- sweep(scld_test, 2, sds, FUN = "/")
  df_test[nums] <- scld_test

  return(
    list(
      train = df_train,
      test = df_test,
      train_id = train_id,
      test_id = test_id,
      folds = all.folds,
      train_means = means,
      train_sds = sds
    )
  )
}
