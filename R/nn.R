do_nn <- function(dat){
  library(tensorflow)
  library(keras)
  reticulate::use_virtualenv("r-tensorflow")

  # Prep data
  train_dataset <- dat$train
  test_dataset <- dat$test

  train_features <- model.matrix(moral_concern ~., dat$train)[, -1]
  train_labels <- dat$train$moral_concern

  test_features <- model.matrix(moral_concern ~., dat$test)[, -1]
  test_labels <- dat$test$moral_concern

  # Define model
  # model <- keras_model_sequential() |>
  #   layer_dense(
  #     units = 64,
  #     activation = "relu",
  #     input_shape = dim(train_features)[2]
  #     ) |>
  #   layer_dense(units = 64,
  #               activation = "relu") |>
  #   layer_dense(units = 1)

  keras_model_sequential() |>
    layer_dense(512, kernel_regularizer = regularizer_l2(0.0001),
                activation = 'elu', input_shape = dim(train_features)[2]) |>
    layer_dropout(0.5) |>
    layer_dense(512, kernel_regularizer = regularizer_l2(0.0001),
                activation = 'elu') |>
    layer_dropout(0.5) |>
    layer_dense(512, kernel_regularizer = regularizer_l2(0.0001),
                activation = 'elu') |>
    layer_dropout(0.5) |>
    layer_dense(512, kernel_regularizer = regularizer_l2(0.0001),
                activation = 'elu') |>
    layer_dropout(0.5) |>
    layer_dense(1) ->
    model

  model |>
    compile(
      loss = "mse",
      optimizer = optimizer_adam(),
      metrics = list("mean_squared_error")
      )

  model |> fit(x = train_features,
               y = train_labels,
               validation_split = 0.2,
               verbose = 0,
               epochs = 500)



  pred <- predict(model, test_features)
  pred_train <- predict(model, train_features)
  save_model_tf(model, 'my_model/')

  out <- list(
    #res_cv = res_tune_ranger,
    res = quote(load_model_tf('my_model/')),
    tune_pars = vector("numeric"),
    rsq = rsq(test_labels, pred, mean(train_labels)),
    rsq_train =  rsq(train_labels, pred_train, mean(train_labels))
  )
  class(out) <- "res_nn"
  return(out)
}


