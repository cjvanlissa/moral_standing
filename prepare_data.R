# In this file, write the R-code necessary to load your original data file
# (e.g., an SPSS, Excel, or SAS-file), and convert it to a data.frame. Then,
# use the function open_data(your_data_frame) or closed_data(your_data_frame)
# to store the data.

library(worcs)

df_full <- read.csv("poms example data.csv", stringsAsFactors = TRUE)

# For privacy, anonymize id
df_full[["id"]] <- as.integer(factor(df_full$id, levels = sample(unique(df_full$id))))

library(tidySEM)

run_everything <- TRUE

# Select items ------------------------------------------------------------

desc <- tidySEM::descriptives(df_full)

scales_list <- yaml::read_yaml("scales_list.yml")

if(any(sapply(scales_list, length) < 3)) stop("Some scales contain fewer than 3 items, not identified.")

remove_variables <- c(
                      # target_group is a higher order representation of this info
                      "target",
                      # and remove pre-combined scale scores
                      "sentience", "agency", "soc_cog", "harmfulness", "mf_harm",
                        "mf_fairness", "mf_liberty", "mf_authority", "mf_loyalty", "mf_sanctity",
                        "trust", "anomie_social_fabric", "anomie_leadership", "value",
                        "conservative")

df_full[remove_variables] <- NULL

yvar <- "moral_concern"

xvars <- c(
  names(df_full)[!names(df_full) %in% c(yvar, unlist(scales_list))],
  names(scales_list))


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

  tab <- data.frame(variable = scal,
                    items = length(indicators),
                    tidySEM::table_fit(res)[, c("Parameters", "chisq", "df", "cfi", "tli", "rmsea", "srmr")])

  tab$comp_rel <- semTools::compRelSEM(res, ord.scale = any(is_ordr))
  scores <- rowMeans(df_tmp[, lapply(.SD, as.numeric), .SDcols = indicators])
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

# Drop scales if the following psychometrics are poor:
drop_scales <- !(tab_psychometrics$cfi > .9 &
  tab_psychometrics$tli > .9 &
  tab_psychometrics$rmsea < .08 &
  tab_psychometrics$comp_rel > .65)

tab_psychometrics[drop_scales, ]

tab_psychometrics <- tab_psychometrics[!drop_scales, ]

write.csv(tab_psychometrics, "tab_psychometrics.csv", row.names = F)

scale_scores <- scale_scores[, !drop_scales]

df_anal <- data.frame(df_full[, -which(names(df_full) %in% unlist(scales_list))],
                      scale_scores)

df_anal$gender <- factor(df_anal$gender, levels = c(1L, 2L), labels = c("male", "female")) # Check if labeling is correct
open_data(df_anal)


