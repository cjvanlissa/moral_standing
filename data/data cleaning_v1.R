# R script to analyze data for:
# Toward a predictive model of moral concern
# R code by: Bastian Jaeger
# Date: 26/03/2025

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

# Load data from both parts
data1 <- import("./data/simdata_part1_raw.csv")
data2 <- import("./data/simdata_part2_raw.csv")

# Label nationality of participants from data set that includes labeled values
data1_labeled <- import("./data/simdata_part1_labels_raw.csv")
data1$nationality <- data1_labeled$nationality
rm("data1_labeled")

# Delete data from previewing the survey, from unfinished surveys, and from participants who did not pledge
data1 <- filter(data1, Status == 2, Finished == 1)
data2 <- filter(data2, Status == 2, Finished == 1)

# Show % of participants who did not pledge to complete the survey in a careful manner and exclude
nrow(filter(data1, pledge == 2))/nrow(data1)*100 # Part 1
nrow(filter(data2, pledge == 2))/nrow(data2)*100 # Part 2
data1 <- filter(data1, pledge == 1)
data2 <- filter(data2, pledge == 1)

# Show % of participants who ignored instructions to not complete the study on a phone and exclude
nrow(filter(data1, device == 4))/nrow(data1)*100 # Part 1
nrow(filter(data2, device == 4))/nrow(data2)*100 # Part 2
#data1 <- filter(data1, device != 4)
#data2 <- filter(data2, device != 4)

# Select relevant variables
data1 <- select(data1, prolificid:comment, -gender_9_TEXT)
data2 <- select(data2, prolificid:comment, -gender_9_TEXT)

# Rename variables that were assessed in both parts
data2 <- rename(data2,
                gender2 = gender,
                age2 = age,
                device2 = device,
                comment2 = comment)

# Merge responses from the two parts
#data <- left_join(select(data2, experience_1_1:comment2, -pledge,
#                  select(data1, prolificid:comment1, -pledge),
#                         by = "prolificid") # Code for real data
data2 <- data2 [1:nrow(data1),] # Code for simulated data
data <- cbind(select(data2, sentience_1_1:comment2, -pledge, -gender2, -age2),
              select(data1, prolificid:comment, -pledge))

# only keep merged data set
rm("data1", "data2")

# Create participant ID variable
data$id <- as.factor(1:nrow(data))

# Recode non-binary gender responses to NA (small numbers make this inappropriate to include in analyses
data$gender <- ifelse(data$gender == 9, NA, data$gender)
data$gender <- ifelse(data$gender == 1, "male", "female")
data$gender <- as.factor(data$gender)

# Recode diet variable
data$diet <- fct_recode(as.factor(data$diet),
                        "omnivore" = "1",
                        "restricted_omnivore" = "2",
                        "vegetarian" = "3",
                        "vegan" = "4",
                        "other" = "5")

# Recode ethnicity self-identification variable to dummy variables for each answer option
data$ethnic_white <- ifelse(grepl("1", data$ethnicity), 1,0)
data$ethnic_black <- ifelse(grepl("2", data$ethnicity), 1,0)
data$ethnic_native <- ifelse(grepl("3", data$ethnicity), 1,0)
data$ethnic_asian <- ifelse(grepl("4", data$ethnicity), 1,0)
data$ethnic_pacific <- ifelse(grepl("5", data$ethnicity), 1,0)
data$ethnic_hispanic <- ifelse(grepl("6", data$ethnicity), 1,0)
data$ethnic_other <- ifelse(grepl("7", data$ethnicity), 1,0)
data$ethnic_blank <- ifelse(grepl("8", data$ethnicity), 1,0)

# Recode "I'd rather not say" answers to NA
data$education <- ifelse(data$education == 6, NA, data$education)
data$income <- ifelse(data$income == 8, NA, data$income)

# Pet variable
data$pet_childhood <- ifelse(data$pet == 0 & is.na(data$pet_attachment), 0, data$pet_attachment)

# Prepare judge characteristics
# Reverse-score Social Dominance Orientation items and create average score
data$sdo_3 <- (data$sdo_3 - 8) * -1
data$sdo_4 <- (data$sdo_4 - 8) * -1
data$sdo_7 <- (data$sdo_8 - 8) * -1
data$sdo_7 <- (data$sdo_8 - 8) * -1

data$sdo <- rowMeans(select(data, sdo_1:sdo_8))

# Reverse-score Right-Wing Authoritarianism items and create average score
data$rwa_1 <- (data$rwa_1 - 8) * -1
data$rwa_4 <- (data$rwa_4 - 8) * -1
data$rwa_5 <- (data$rwa_5 - 8) * -1

data$rwa <- rowMeans(select(data, rwa_1:rwa_6))

# Reverse-score HEXACO items and create average scores per dimension
data$hexaco_12 <- (data$hexaco_12 - 8) * -1
data$hexaco_18 <- (data$hexaco_18 - 8) * -1
data$hexaco_24 <- (data$hexaco_24 - 8) * -1
data$hexaco_11 <- (data$hexaco_11 - 8) * -1
data$hexaco_17 <- (data$hexaco_17 - 8) * -1
data$hexaco_4 <- (data$hexaco_4 - 8) * -1
data$hexaco_22 <- (data$hexaco_22 - 8) * -1
data$hexaco_3 <- (data$hexaco_3 - 8) * -1
data$hexaco_9 <- (data$hexaco_9 - 8) * -1
data$hexaco_8 <- (data$hexaco_8 - 8) * -1
data$hexaco_20 <- (data$hexaco_20 - 8) * -1
data$hexaco_7 <- (data$hexaco_7 - 8) * -1

data$hexaco_hh <- rowMeans(select(data, hexaco_6, hexaco_12, hexaco_18, hexaco_24)) # Honesty-Humility
data$hexaco_emo <- rowMeans(select(data, hexaco_5, hexaco_11, hexaco_17, hexaco_23)) # Emotionality
data$hexaco_ex <- rowMeans(select(data, hexaco_4, hexaco_10, hexaco_16, hexaco_22)) # Extraversion
data$hexaco_ag <- rowMeans(select(data, hexaco_3, hexaco_9, hexaco_15, hexaco_21)) # Agreeableness
data$hexaco_con <- rowMeans(select(data, hexaco_2, hexaco_8, hexaco_14, hexaco_20)) # Conscientiousness
data$hexaco_op <- rowMeans(select(data, hexaco_1, hexaco_7, hexaco_13, hexaco_19)) # Openness to Experience

# Rename trust variable
data <- rename(data,
               trust = trust_1)

# Reverse-score Actively Open-Minded Thinking items and create average score
data$aot_2 <- (data$aot_2 - 8) * -1
data$aot_4 <- (data$aot_4 - 8) * -1
data$aot_5 <- (data$aot_5 - 8) * -1
data$aot_6 <- (data$aot_6 - 8) * -1
data$aot_7 <- (data$aot_7 - 8) * -1
data$aot_8 <- (data$aot_8 - 8) * -1
data$aot_10 <- (data$aot_10 - 8) * -1
data$aot_13 <- (data$aot_13 - 8) * -1

data$aot <- rowMeans(select(data, aot_1:aot_13))

# Create average Moral Disgust Sensitivity score
data$moraldisgust <- rowMeans(select(data, moraldisgust_1:moraldisgust_7))

# Reverse-score Empathy items and create average scores per dimension
data$empathy_2 <- (data$empathy_2 - 8) * -1
data$empathy_5 <- (data$empathy_5 - 8) * -1
data$empathy_9 <- (data$empathy_9 - 8) * -1
data$empathy_12 <- (data$empathy_12 - 8) * -1
data$empathy_13 <- (data$empathy_13 - 8) * -1
data$empathy_18 <- (data$empathy_18 - 8) * -1
data$empathy_20 <- (data$empathy_20 - 8) * -1

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

# Save full data set
data_full <- data

# Prepare target characteristics
# Make data set long
data <- data_full %>%
  gather(entity, moral_concern_1, concern_1_1:concern_1_30) %>%
  select(id, entity, moral_concern_1) # Moral concern item 1

temp <- data_full %>%
  gather(entity, moral_concern_2, concern_2_1:concern_2_30) %>%
  select(id, entity, moral_concern_2)
data <- cbind(data, select(temp, moral_concern_2)) # Moral concern item 2

temp <- data_full %>%
  gather(entity, moral_concern_3, concern_3_1:concern_3_30) %>%
  select(id, entity, moral_concern_3)
data <- cbind(data, select(temp, moral_concern_3)) # Moral concern item 3

temp <- data_full %>%
  gather(entity, sentience_1, sentience_1_1:sentience_1_30) %>%
  select(id, entity, sentience_1)
data <- cbind(data, select(temp, sentience_1)) # Perceived sentience item 1

temp <- data_full %>%
  gather(entity, sentience_2, sentience_2_1:sentience_2_30) %>%
  select(id, entity, sentience_2)
data <- cbind(data, select(temp, sentience_2)) # Perceived sentience item 2

temp <- data_full %>%
  gather(entity, sentience_3, sentience_3_1:sentience_3_30) %>%
  select(id, entity, sentience_3)
data <- cbind(data, select(temp, sentience_3)) # Perceived sentience item 3

temp <- data_full %>%
  gather(entity, agency_1, agency_1_1:agency_1_30) %>%
  select(id, entity, agency_1)
data <- cbind(data, select(temp, agency_1)) # Perceived agency item 1

temp <- data_full %>%
  gather(entity, agency_2, agency_2_1:agency_2_30) %>%
  select(id, entity, agency_2)
data <- cbind(data, select(temp, agency_2)) # Perceived agency item 2

temp <- data_full %>%
  gather(entity, agency_3, agency_3_1:agency_3_30) %>%
  select(id, entity, agency_3)
data <- cbind(data, select(temp, agency_3)) # Perceived agency item 3

temp <- data_full %>%
  gather(entity, socog_1, socog_1_1:socog_1_30) %>%
  select(id, entity, socog_1)
data <- cbind(data, select(temp, socog_1)) # Perceived social-cognitive capacities item 1

temp <- data_full %>%
  gather(entity, socog_2, socog_2_1:socog_2_30) %>%
  select(id, entity, socog_2)
data <- cbind(data, select(temp, socog_2)) # Perceived social-cognitive capacities item 2

temp <- data_full %>%
  gather(entity, socog_3, socog_3_1:socog_3_30) %>%
  select(id, entity, socog_3)
data <- cbind(data, select(temp, socog_3)) # Perceived social-cognitive capacities item 3

temp <- data_full %>%
  gather(entity, harmful_1, harmful_1_1:harmful_1_30) %>%
  select(id, entity, harmful_1)
data <- cbind(data, select(temp, harmful_1)) # Perceived harmfulness item 1

temp <- data_full %>%
  gather(entity, harmful_2, harmful_2_1:harmful_2_30) %>%
  select(id, entity, harmful_2)
data <- cbind(data, select(temp, harmful_2)) # Perceived harmfulness item 2

temp <- data_full %>%
  gather(entity, beautiful, beautiful_1:beautiful_30) %>%
  select(id, entity, beautiful)
data <- cbind(data, select(temp, beautiful)) # Perceived beauty

temp <- data_full %>%
  gather(entity, similar, similar_1:similar_30) %>%
  select(id, entity, similar)
data <- cbind(data, select(temp, similar)) # Perceived similarity to self

temp <- data_full %>%
  gather(entity, utility, utility_1:utility_30) %>%
  select(id, entity, utility)
data <- cbind(data, select(temp, utility)) # Perceived usefulness to self or others

temp <- data_full %>%
  gather(entity, vulnerable, vulnerable_1:vulnerable_30) %>%
  select(id, entity, vulnerable)
data <- cbind(data, select(temp, vulnerable)) # Perceived vulnerability

data <- arrange(data, by = id)
rm("temp")

# Rename entities
data$entity <- fct_recode(as.factor(data$entity),
                          "family member" = "concern_1_1",
                          "transgender person" = "concern_1_2",
                          "charity worker" = "concern_1_3",
                          "American citizen" = "concern_1_4",
                          "Chinese citize" = "concern_1_5",
                          "asylum seeker" = "concern_1_6",
                          "member of opposing political party" = "concern_1_7",
                          "dolphin" = "concern_1_8",
                          "old-growth forest" = "concern_1_9",
                          "fish" = "concern_1_10",
                          "apple tree" = "concern_1_11",
                          "murderer" = "concern_1_12",
                          "human in a persistent vegetative state" = "concern_1_13",
                          "1-year-old human infant" = "concern_1_14",
                          "6-week-old human embryo" = "concern_1_15",
                          "24-week-old human fetus" = "concern_1_16",
                          "octopus" = "concern_1_17",
                          "dog" = "concern_1_18",
                          "pig" = "concern_1_19",
                          "chicken" = "concern_1_20",
                          "shrimp" = "concern_1_21",
                          "rat" = "concern_1_22",
                          "pigeon" = "concern_1_23",
                          "spider" = "concern_1_24",
                          "chimpanzee" = "concern_1_25",
                          "wolf" = "concern_1_26",
                          "deer" = "concern_1_27",
                          "earthworm" = "concern_1_28",
                          "butterfly" = "concern_1_29",
                          "ChatGPT (advanced AI system)" = "concern_1_30")

# Create average scores for moral concern, perceived sentience, agency, social-cognitive capacities and harmfulness
data$moral_concern <- rowMeans(select(data, moral_concern_1:moral_concern_3))
data$sentience <- rowMeans(select(data, sentience_1:sentience_3))
data$agency <- rowMeans(select(data, agency_1:agency_3))
data$socog <- rowMeans(select(data, socog_1:socog_3))
data$harmful <- rowMeans(select(data, harmful_1:harmful_2))

# Merge with judge and target characteristics data
data <- left_join(data, select(data_full, prolificid, sdo_1:util_ih, device2, comment2, -diet_5_TEXT,
                               -ethnicity, -ethnicity_7_TEXT), by = "id")

# Order variables
data <- select(data, id, prolificid, entity, contains("moral_concern"), contains("sentience"), contains("agency"),
               contains("socog"), contains("harmful"), beautiful, similar, utility, vulnerable, contains("sdo"),
               contains("rwa"), contains("hexaco"), trust, contains("aot"), contains("moraldisgust"),
               contains("empathy"), contains("moralfound"), contains("identity"), contains("util"),
               gender, age, nationality, contains("ethnic"), pet, pet_attachment, pet_childhood, conservative,
               religious, education, income, diet, device, device2, comment, comment2)

worcs::closed_data(data)
# Save the cleaned data set
#write_csv(data, "simdata_clean.csv")

# Save a data frame that lists all variable names (to create the codebook)
#codebook <- tibble(variable_name = names(data), description = NA)
#write_csv(codebook, "variable_names.csv")
