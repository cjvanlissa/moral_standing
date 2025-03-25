get_data <- function(){
  out <- worcs::load_data(to_envir = FALSE)$df_anal
  class(out) <- "data.frame"
  # Subsample cases to run the code quickly during development:
  out <- out[out$id %in% sample(unique(out$id), 200), ]
  return(out)
}

select_features <- function(dat, features){
  out <- lapply(features, function(f){
    dat$train <- dat$train[, c("moral_concern", f)]
    dat$test <- dat$test[, c("moral_concern", f)]
    dat$train_means <- dat$train_means[names(dat$train_means) %in% f]
    dat$train_sds <- dat$train_sds[names(dat$train_sds) %in% f]
    dat
  })
  names(out) <- names(features)
  return(out)
}
