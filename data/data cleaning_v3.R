# R script to analyze data for:
# Toward a predictive model of moral concern
# Date: 16/04/2025

# Setup ---------------------------------------------------------------------------------------

# Load packages
library(cowplot)
library(rio)
library(grid)
library(gridExtra)
library(broom)
library(psych)
library(ICC)
library(viridis)
library(tidyverse)

# Prepare data --------------------------------------------------------------------------------

# Load data
data <- import("Simulated data/simdata_raw.csv")

# Label nationality of participants from data set that includes labeled values
data_labeled <- import("Simulated data/simdata_labels_raw.csv")
data$nationality <- data_labeled$nationality
rm("data_labeled")

# Delete data from previewing the survey, from unfinished surveys, and from participants who did not pledge
data <- filter(data, Status == 2, Finished == 1)

# Show % of participants who did not pledge to complete the survey in a careful manner and exclude
nrow(filter(data, pledge == 2))/nrow(data)*100
data <- filter(data, pledge == 1)

# Show % of participants who ignored instructions to not complete the study on a phone and exclude
nrow(filter(data, device == 4))/nrow(data)*100
#data1 <- filter(data, device != 4) # Activate this code for the real data

# Create participant ID variable
data$id <- as.factor(1:nrow(data))

# Select relevant variables
data <- select(data, id, prolificid, entity1:entity10, pledge:comment, -gender_9_TEXT)

# Recode non-binary gender responses to NA (small numbers make this inappropriate to include in analyses
data$gender <- ifelse(data$gender == 9, NA, data$gender)
data$gender <- ifelse(data$gender == 1, "male", "female")
data$gender <- as.factor(data$gender)

# Recode diet variable
data$diet <- factor(data$diet, levels = 1:5, labels = c("omnivore",
                                                        "restricted_omnivore",
                                                        "vegetarian",
                                                        "vegan",
                                                        "other"))

# Recode ethnicity self-identification variable to dummy variables for each answer option
data$ethnic_white <- ifelse(grepl("1", data$ethnicity), 1, 0)
data$ethnic_black <- ifelse(grepl("2", data$ethnicity), 1, 0)
data$ethnic_native <- ifelse(grepl("3", data$ethnicity), 1, 0)
data$ethnic_asian <- ifelse(grepl("4", data$ethnicity), 1, 0)
data$ethnic_pacific <- ifelse(grepl("5", data$ethnicity), 1, 0)
data$ethnic_hispanic <- ifelse(grepl("6", data$ethnicity), 1, 0)
data$ethnic_other <- ifelse(grepl("7", data$ethnicity), 1, 0)
data$ethnic_blank <- ifelse(grepl("8", data$ethnicity), 1, 0)

# Recode "I'd rather not say" answers to NA
data$education <- ifelse(data$education == 6, NA, data$education)
data$income <- ifelse(data$income == 8, NA, data$income)

# Pet variable
data$pet_childhood <- ifelse(data$pet == 0 & is.na(data$pet_attachment), 0, data$pet_attachment)

# Prepare judge characteristics
# Reverse-score Social Dominance Orientation items and create average score
data$sdo_3 <- 8 - data$sdo_3
data$sdo_4 <- 8 - data$sdo_4
data$sdo_7 <- 8 - data$sdo_7
data$sdo_8 <- 8 - data$sdo_8

data$sdo <- rowMeans(select(data, sdo_1:sdo_8))

# Reverse-score Right-Wing Authoritarianism items and create average score
data$rwa_1 <- 8 - data$rwa_1
data$rwa_4 <- 8 - data$rwa_4
data$rwa_5 <- 8 - data$rwa_5

data$rwa <- rowMeans(select(data, rwa_1:rwa_6))

# Reverse-score HEXACO items and create average scores per dimension
data$hexaco_12 <- 8 - data$hexaco_12
data$hexaco_18 <- 8 - data$hexaco_18
data$hexaco_24 <- 8 - data$hexaco_24
data$hexaco_11 <- 8 - data$hexaco_11
data$hexaco_17 <- 8 - data$hexaco_17
data$hexaco_4 <- 8 - data$hexaco_4
data$hexaco_22 <- 8 - data$hexaco_22
data$hexaco_3 <- 8 - data$hexaco_3
data$hexaco_9 <- 8 - data$hexaco_9
data$hexaco_8 <- 8 - data$hexaco_8
data$hexaco_20 <- 8 - data$hexaco_20
data$hexaco_7 <- 8 - data$hexaco_7

data$hexaco_hh <- rowMeans(select(data, hexaco_6, hexaco_12, hexaco_18, hexaco_24)) # Honesty-Humility
data$hexaco_emo <- rowMeans(select(data, hexaco_5, hexaco_11, hexaco_17, hexaco_23)) # Emotionality
data$hexaco_ex <- rowMeans(select(data, hexaco_4, hexaco_10, hexaco_16, hexaco_22)) # Extraversion
data$hexaco_ag <- rowMeans(select(data, hexaco_3, hexaco_9, hexaco_15, hexaco_21)) # Agreeableness
data$hexaco_con <- rowMeans(select(data, hexaco_2, hexaco_8, hexaco_14, hexaco_20)) # Conscientiousness
data$hexaco_op <- rowMeans(select(data, hexaco_1, hexaco_7, hexaco_13, hexaco_19)) # Openness to Experience

# Reverse-score Actively Open-Minded Thinking items and create average score
data$aot_2 <- 8 - data$aot_2
data$aot_4 <- 8 - data$aot_4
data$aot_5 <- 8 - data$aot_5
data$aot_6 <- 8 - data$aot_6
data$aot_7 <- 8 - data$aot_7
data$aot_8 <- 8 - data$aot_8
data$aot_10 <- 8 - data$aot_10
data$aot_13 <- 8 - data$aot_13

data$aot <- rowMeans(select(data, aot_1:aot_13))

# Create average Moral Disgust Sensitivity score
data$moraldisgust <- rowMeans(select(data, moraldisgust_1:moraldisgust_7))

# Reverse-score Empathy items and create average scores per dimension
data$empathy_2 <- 8 - data$empathy_2
data$empathy_5 <- 8 - data$empathy_5
data$empathy_9 <- 8 - data$empathy_9
data$empathy_12 <- 8 - data$empathy_12
data$empathy_13 <- 8 - data$empathy_13
data$empathy_18 <- 8 - data$empathy_18
data$empathy_20 <- 8 - data$empathy_20

data$empathy_pt <- rowMeans(select(data, empathy_1:empathy_7)) # Perspective-taking
data$empathy_ec <- rowMeans(select(data, empathy_8:empathy_14)) # Empathic concern
data$empathy_pd <- rowMeans(select(data, empathy_15:empathy_21)) # Personal distress

# Create average Moral Foundations scores per dimension
data$moralfound_care <- rowMeans(select(data, moralfound_1:moralfound_3)) # Care
data$moralfound_fair <- rowMeans(select(data, moralfound_4:moralfound_6)) # Fairness
data$moralfound_lib <- rowMeans(select(data, moralfound_7:moralfound_9)) # Liberty
data$moralfound_aut <- rowMeans(select(data, moralfound_10:moralfound_12)) # Authority
data$moralfound_ing <- rowMeans(select(data, moralfound_13:moralfound_15)) # Ingroup
data$moralfound_pur <- rowMeans(select(data, moralfound_16:moralfound_18)) # Purity

# Create average Identification with all living beings score
data$identity_allbeings <- rowMeans(select(data, identity1_3, identity2_3, identity3_3, identity4_3))

# Create average Utilitarianism scores per dimension
data$util_ib <- rowMeans(select(data, util_1:util_5)) # Impartial beneficence
data$util_ih <- rowMeans(select(data, util_6:util_9)) # Instrumental harm

# Randomly select 10 entities per participant (only needed for simulated data, delete for real data)
# Rename entities
entities <- c("family member","transgender person","charity worker","American citizen",
              "Chinese citizen","asylum seeker","member of opposing political party","dolphin",
              "old-growth forest","fish","apple tree","murderer",
              "human in a persistent vegetative state","1-year-old human infant",
              "6-week-old human embryo","24-week-old human fetus","octopus","dog","pig","chicken",
              "shrimp","rat","pigeon","spider","chimpanzee","wolf","deer","earthworm","butterfly",
              "ChatGPT (advanced AI system)")
data$entity1 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity2 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity3 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity4 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity5 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity6 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity7 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity8 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity9 <-  rep(sample(entities, nrow(data), replace = TRUE))
data$entity10 <-  rep(sample(entities, nrow(data), replace = TRUE))

# Save full data set
data_full <- data

# Prepare target characteristics
# Make data set long
data <- data_full %>%
  gather(trial, entity, entity1:entity10) %>%
  select(id, entity) # Entities

temp <- data_full %>%
  gather(entity, moral_concern_1, concern_1_1:concern_1_10) %>%
  select(id, entity, moral_concern_1)
data <- cbind(data, select(temp, moral_concern_1)) # Moral concern item 1

temp <- data_full %>%
  gather(entity, moral_concern_2, concern_2_1:concern_2_10) %>%
  select(id, entity, moral_concern_2)
data <- cbind(data, select(temp, moral_concern_2)) # Moral concern item 2

temp <- data_full %>%
  gather(entity, moral_concern_3, concern_3_1:concern_3_10) %>%
  select(id, entity, moral_concern_3)
data <- cbind(data, select(temp, moral_concern_3)) # Moral concern item 3

temp <- data_full %>%
  gather(entity, sentience_1, sentience_1_1:sentience_1_10) %>%
  select(id, entity, sentience_1)
data <- cbind(data, select(temp, sentience_1)) # Perceived sentience item 1

temp <- data_full %>%
  gather(entity, sentience_2, sentience_2_1:sentience_2_10) %>%
  select(id, entity, sentience_2)
data <- cbind(data, select(temp, sentience_2)) # Perceived sentience item 2

temp <- data_full %>%
  gather(entity, sentience_3, sentience_3_1:sentience_3_10) %>%
  select(id, entity, sentience_3)
data <- cbind(data, select(temp, sentience_3)) # Perceived sentience item 3

temp <- data_full %>%
  gather(entity, agency_1, agency_1_1:agency_1_10) %>%
  select(id, entity, agency_1)
data <- cbind(data, select(temp, agency_1)) # Perceived agency item 1

temp <- data_full %>%
  gather(entity, agency_2, agency_2_1:agency_2_10) %>%
  select(id, entity, agency_2)
data <- cbind(data, select(temp, agency_2)) # Perceived agency item 2

temp <- data_full %>%
  gather(entity, agency_3, agency_3_1:agency_3_10) %>%
  select(id, entity, agency_3)
data <- cbind(data, select(temp, agency_3)) # Perceived agency item 3

temp <- data_full %>%
  gather(entity, socog_1, socog_1_1:socog_1_10) %>%
  select(id, entity, socog_1)
data <- cbind(data, select(temp, socog_1)) # Perceived social-cognitive capacities item 1

temp <- data_full %>%
  gather(entity, socog_2, socog_2_1:socog_2_10) %>%
  select(id, entity, socog_2)
data <- cbind(data, select(temp, socog_2)) # Perceived social-cognitive capacities item 2

temp <- data_full %>%
  gather(entity, socog_3, socog_3_1:socog_3_10) %>%
  select(id, entity, socog_3)
data <- cbind(data, select(temp, socog_3)) # Perceived social-cognitive capacities item 3

temp <- data_full %>%
  gather(entity, harmful_1, harmful_1_1:harmful_1_10) %>%
  select(id, entity, harmful_1)
data <- cbind(data, select(temp, harmful_1)) # Perceived harmfulness item 1

temp <- data_full %>%
  gather(entity, harmful_2, harmful_2_1:harmful_2_10) %>%
  select(id, entity, harmful_2)
data <- cbind(data, select(temp, harmful_2)) # Perceived harmfulness item 2

temp <- data_full %>%
  gather(entity, beautiful, beautiful_1:beautiful_10) %>%
  select(id, entity, beautiful)
data <- cbind(data, select(temp, beautiful)) # Perceived beauty

temp <- data_full %>%
  gather(entity, similar, similar_1:similar_10) %>%
  select(id, entity, similar)
data <- cbind(data, select(temp, similar)) # Perceived similarity to self

temp <- data_full %>%
  gather(entity, utility, utility_1:utility_10) %>%
  select(id, entity, utility)
data <- cbind(data, select(temp, utility)) # Perceived usefulness to self or others

temp <- data_full %>%
  gather(entity, vulnerable, vulnerable_1:vulnerable_10) %>%
  select(id, entity, vulnerable)
data <- cbind(data, select(temp, vulnerable)) # Perceived vulnerability

data <- arrange(data, by = id)
rm("temp")

# Create average scores for moral concern, perceived sentience, agency, social-cognitive capacities and harmfulness
data$moral_concern <- rowMeans(select(data, moral_concern_1:moral_concern_3))
data$sentience <- rowMeans(select(data, sentience_1:sentience_3))
data$agency <- rowMeans(select(data, agency_1:agency_3))
data$socog <- rowMeans(select(data, socog_1:socog_3))
data$harmful <- rowMeans(select(data, harmful_1:harmful_2))

# Merge with judge and target characteristics data
data <- left_join(data, select(data_full, id, prolificid, pledge, sdo_1:util_9, gender:util_ih, -diet_5_TEXT,
                               -ethnicity, -ethnicity_7_TEXT), by = "id")

# Order data frame
data <- select(data, id, prolificid, entity, contains("moral_concern"), contains("sentience"),
               contains("agency"), contains("socog"), contains("harmful"), beautiful, similar, utility, vulnerable,
               contains("sdo"), contains("rwa"), contains("hexaco"), trust, contains("aot"),
               contains("moraldisgust"), contains("empathy"), contains("moralfound"), contains("identity"),
               contains("util_"), gender, age, nationality, contains("ethnic"), contains("pet"), conservative,
               religious, education, income, diet, device, comment)

# Save the cleaned data set
#write_csv(data, "simdata_clean.csv")

# Save a data frame that lists all variable names (to create the codebook)
#codebook <- tibble(variable_name = names(data), description = NA)
#write_csv(codebook, "variable_names.csv")
