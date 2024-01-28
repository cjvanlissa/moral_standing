if(FALSE){
library(keras)
reticulate::use_virtualenv("r-tensorflow")
train_features <- model.matrix(moral_concern ~., dat$train)[, -1]
train_labels <- dat$train$moral_concern
normalizer <- layer_normalization(axis = -1L)

# Fit the state of the preprocessing layer to the data by calling adapt():
adapt(normalizer, as.matrix(train_features))

# Calculate the mean and variance, and store them in the layer:
print(normalizer$mean)

# When the layer is called, it returns the input data, with each feature independently normalized.
first <- as.matrix(train_features[1,])
build_and_compile_model <- function(norm) {
  model <- keras_model_sequential() |>
    norm() |>
    layer_dense(64, activation = 'relu') |>
    layer_dense(64, activation = 'relu') |>
    layer_dense(1)

  model |> compile(
    loss = 'mean_squared_error',
    optimizer = optimizer_adam(0.001)
  )

  model
}

dnn_model <- build_and_compile_model(normalizer)
summary(dnn_model)

history <- dnn_model |> fit(
  as.matrix(train_features),
  as.matrix(train_labels),
  validation_split = 0.2,
  verbose = 0,
  epochs = 100
)

plot(history)

save_model_tf(dnn_model, 'my_model/')

#model <- load_model_tf('my_model/')

test_features <- model.matrix(moral_concern ~., dat$test)[, -1]
test_labels <- dat$test$moral_concern
# Collect the results on the test set:
test_results <- list()
test_results[['dnn_model']] <- dnn_model |> evaluate(
  as.matrix(test_features),
  as.matrix(test_labels),
  verbose = 0
)

# Make predictions
# You can now make predictions with the dnn_model on the test set using Keras predict() and review the loss:

test_predictions <- predict(dnn_model, as.matrix(test_features))


}
