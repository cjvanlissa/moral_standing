get_data <- function(){
  out <- worcs::load_data(to_envir = FALSE)$df_anal
  class(out) <- "data.frame"
  # Subsample cases to run the code quickly during development:
  out <- out[out$id %in% sample(unique(out$id), 200), ]
  return(out)
}
