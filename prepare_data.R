# In this file, write the R-code necessary to load your original data file
# (e.g., an SPSS, Excel, or SAS-file), and convert it to a data.frame. Then,
# use the function open_data(your_data_frame) or closed_data(your_data_frame)
# to store the data.

library(worcs)
library(tidySEM)

df_full <- read.csv("./data/simdata_clean.csv")

# For privacy, anonymize id
df_full[["id"]] <- as.integer(factor(df_full$id, levels = sample(unique(df_full$id))))
df_full[c("prolificid", grep("^comment", names(df_full), value = TRUE))] <- NULL

# Select items ------------------------------------------------------------

desc <- tidySEM::descriptives(df_full)
write.csv(desc, "item_descriptives.csv", row.names = FALSE)

scales_list <- yaml::read_yaml("scales_list.yml")
selected_variables <- readxl::read_xlsx("./data/codebook.xlsx")
selected_variables <- selected_variables[rowSums(selected_variables[, c("target attribute predictor", "judge attribute predictor", "demographic predictor")], na.rm = TRUE) > 0, ]

# remove_variables <- c(
#                       # target_group is a higher order representation of this info
#                       "target",
#                       # and remove pre-combined scale scores
#                       "sentience", "agency", "soc_cog", "harmfulness", "mf_harm",
#                         "mf_fairness", "mf_liberty", "mf_authority", "mf_loyalty", "mf_sanctity",
#                         "trust", "anomie_social_fabric", "anomie_leadership", "value",
#                         "conservative")
#
# df_full[remove_variables] <- NULL

yvar <- "moral_concern"

xvars <- selected_variables$variable_name

# Missing data ------------------------------------------------------------

# Code missings
# TO DO

# # Descriptives
# desc <- tidySEM::descriptives(df)
#
# # Impute
# if(run_everything){
#   set.seed(9808)
#   df_imp <- missRanger::missRanger(df)
#   saveRDS(df_imp, "df_imp.RData")
# } else {
#   df_imp <- readRDS("manuscript/df_imp.RData")
# }


# Psychometrics -----------------------------------------------------------

library(data.table)
df <- data.table(df_full)
df <- df[, .SD, .SDcols = unlist(scales_list)]
desc <- tidySEM::descriptives(df)
# Variables with < 10 unique values are treated as ordinal
is_ordered <- desc$name[desc$unique < 10]
df[, (is_ordered) := lapply(.SD, ordered), .SDcols = is_ordered]

# Make data long for multilevel CFA
psychmet <- lapply(names(scales_list), function(scal){
  #scal = names(scales_list)[1]
  indicators <- scales_list[[scal]]
  syntx <- paste0(scal, "=~", paste0(indicators,
                                     collapse = " + "
  ))
  if(length(indicators) == 2){
    syntx <- paste0(scal, "=~", paste0(paste0("a*", indicators),
                                       collapse = " + "
    ))
  }
  df_tmp <- df[, .SD, .SDcols = indicators]

  # Any ordered
  is_ordr <- sapply(df_tmp, inherits, what = "ordered")
  # CFA
  res <- lavaan::cfa(
    model = syntx,
    data = df_tmp,
    ordered = if(any(is_ordr)){names(df_tmp)[is_ordr]} else {NULL},
    std.lv = TRUE,
    auto.fix.first = FALSE
  )

  fits <- try(tidySEM::table_fit(res)[, c("Parameters", "chisq", "df", "cfi", "tli", "rmsea", "srmr")], silent = TRUE)
  if(inherits(fits, "try-error")){
    fits <- structure(list(Parameters = NA, chisq = NA, df = NA,
                           cfi = NA, tli = NA, rmsea = NA,
                           srmr = NA), class = c("tidy_fit", "data.frame"
                           ), row.names = c(NA, -1L))
  }
  tab <- data.frame(variable = scal,
                    items = length(indicators),
                    fits)

  tab$comp_rel <- semTools::compRelSEM(res, ord.scale = any(is_ordr))
  scores <- rowMeans(df_tmp[, lapply(.SD, function(x){as.numeric(as.character(x))}), .SDcols = indicators])
  return(
    list(
      psychometrics = tab,
      scores = scores
    )
  )
})

tab_psychometrics <- do.call(rbind, lapply(psychmet, `[[`, 1))
scale_scores <- data.frame(do.call(cbind, lapply(psychmet, `[[`, 2)))
names(scale_scores) <- tab_psychometrics$variable
write.csv(tab_psychometrics, "tab_psychometrics.csv", row.names = F)

if(!all(sapply(names(scale_scores), function(n) isTRUE(all(scale_scores[[n]] == df_full[[n]]))))){
  stop("Bastian's scales are not the same as Caspar's")
}

# Drop scales if the following psychometrics are poor:
drop_scales <- which(tab_psychometrics$comp_rel < 0) # change to .6 for real data

if(length(drop_scales) > 0){
  tab_psychometrics <- tab_psychometrics[-drop_scales, ]
  scale_scores <- scale_scores[, -drop_scales]
}

df_anal <- data.frame(df_full[, c("id", yvar, setdiff(selected_variables$variable_name, names(scales_list)))],
                      scale_scores)

open_data(df_anal)
