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
  fold <- sample.int(k, replace = TRUE, size = length(unique(train_id)))
  all.folds <- lapply(1:k, function(i){
    theseids <- which(train_id %in% unique(train_id)[fold == i])
  })
  names(all.folds) <- 1:k
  return(
    list(
      train = df_train,
      test = df_test,
      train_id = train_id,
      test_id = test_id,
      folds = all.folds
    )
  )
}
