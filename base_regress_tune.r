# General template script for the regression learners of the base layer
# Uses a predefined parameters table with the estimated parameters that will be used by the feauture learner
# But also helps refine the parameters table which is the output in order to best select the hyperparamters
# in case the predefined parameter table does not exist, the intial parameters can be set manually
# This file should be run from the command line using parallel processing specifying the index of the features to tune for
# The index should be an integer from 1 - 17
# But can be run from the R console by setting the index manually

library(dplyr)
library(readr)
library(tidyverse)
library(xgboost)
library(caret)
library(caTools)

# Set the index for the learner to tune for from the command line (should be an integer from 1 - 17)
args <- commandArgs(trailingOnly = TRUE)
index <- as.numeric(args[1])

# Set the working directory
setwd("")

# Get the parameters from stored Parameters file
parameters <- read.csv("XGB_reg_parameters.csv")
cat("\n Parameters: \n")
print(dim(parameters))

# select the parameters corrsponding to the index
selected_parameters <- parameters[index, ]
rm(parameters)
cat("\n Parameters: \n")
print(selected_parameters)
cat("\n\n")

# The parameters are initialised based on the hyperparameter file but can be modified manually here
selected_feature <- selected_parameters$Feature
selected_rna_set <- selected_parameters$RNA_set
selected_trees <- as.numeric(selected_parameters$Trees) + 500
selected_eta <- selected_parameters$Eta
selected_gamma <- selected_parameters$Gamma
selected_depth <- selected_parameters$Max_depth
selected_min_child <- 1

rm(selected_parameters)

# Define the extra parameters
selected_seed <- 99

# Get the corresonding rna set
rna_list <- list(
  transcripts_per_million = "tpm_set",
  scaled_transcripts_per_million = "scld_tpm",
  log_scaled_transcripts_per_million = "log_scld_tpm",
  log_transcripts_per_million = "log_tpm",
  expected_counts = "exp",
  scaled_expected_counts = "scld_exp",
  log_expected_counts = "log_exp",
  log_scaled_expected_counts = "log_scld_exp"
)

# Get the corresonding rna set based on the hyperparameter selection
rna_selection_name <- rna_list[[selected_rna_set]]

rna_data_path <- "train_"

rna_set <- read.csv(
  paste0(
    rna_data_path,
    rna_selection_name,
    "_soi.csv"
  ),
  row.names = 1
)

# HRD scores
ori_hrd <- read_tsv("TCGA.HRD_withSampleID.txt")

# Pericentromeric CNVs
peri_cnv <- read.csv("lim_alpha_incl_TCGA_pericentro.csv") %>%
  mutate_all(~ replace(., is.na(.), 0)) %>%
  mutate(sampleID = gsub("-", ".", sampleID))
cat("\n\n pericentromeric data: \n")
print(head(peri_cnv[, 1:10]))

cat("\n\n All dfs loaded \n")

# Format the HRD data
t_hrd <- as.data.frame(t(ori_hrd))
first_hrd <- t_hrd
colnames(first_hrd) <- t_hrd[1, ]
hrd <- as.data.frame(first_hrd[-1, ]) %>%
  mutate_all(as.numeric) %>%
  rename(loh_hrd = "hrd-loh") %>%
  mutate(new = str_replace_all(rownames(.), "-", "\\."))

rownames(hrd) <- hrd$new
hrd <- hrd %>%
  select(-new)

cat("\n\n hrd data: \n")
print(head(hrd))

rm(t_hrd)
rm(first_hrd)

# Merge the HRD and pericentromeric data
full_cin <- merge(
  hrd,
  peri_cnv,
  by.x = "row.names",
  by.y = "sampleID"
) %>%
  mutate(Row.names = str_replace_all(Row.names, "-", ".")) %>%
  column_to_rownames("Row.names")

cat("\n\n full cin data: \n")
print(head(full_cin))
cat("\n\n")

rm(hrd)
rm(peri_cnv)

# MODELLING

# Initialise the dataframe to store the metrics
aneu_reg_metrics_df <- data.frame(
  RNA_set = character(),
  Trees = numeric(),
  Feature = character(),
  Max_depth = numeric(),
  Child_weight = numeric(),
  Eta = numeric(),
  Gamma = numeric(),
  Trained_RMSE = numeric(),
  Test_RMSE = numeric(),
  Seed = numeric()
)

# Create the full dataframe
full_df <- merge(rna_set, full_cin, by = "row.names")
print(head(rna_set[,1:5]))
rm(rna_set)
cat("\n\n full_df: \n")
print(head(full_df[, 1:5]))
cat("\n\n")

# Define the labels
y <- as.numeric(full_df[[selected_feature]])

# Define the predictorss
X <- full_df %>% select(-c("Row.names", colnames(full_cin)))
cat("\n\n Predictors: \n")
print(head(X[, 1:5]))
cat("\n\n")

# Create the DMatrix
xgb_data <- xgb.DMatrix(data = as.matrix(X), label = y)
rm(X)
rm(y)

# Define the grid for the hyperparameter tuning
# The extent of the grid can be modified to include more values
grid <- expand.grid(
  eta = seq(selected_eta - 0.01, selected_eta + 0.1, 0.1),
  depth = seq(selected_depth, selected_depth + 2, 1),
  min_child = seq(selected_min_child, selected_min_child + 2, 1),
  gamma = seq(selected_gamma - 0.1, selected_gamma + 0.1, 0.1)
)

# Loop over the grid
for (j in 1:nrow(grid)) {
  for (param in names(grid)) {
    assign(paste0("selected_", param), grid[j, param])
  }

  set.seed(selected_seed)

  cat(paste0(
    "\t\t eta: ", selected_eta,
    "\t\t gamma: ", selected_gamma,
    "\t\t depth: ", selected_depth,
    "\t\t trees: ", selected_trees,
    "\t\t child_weight: ", selected_min_child,
    "\n"
  ))

  # train the model
  m_xgb_untuned <- xgb.cv(
    data = xgb_data,
    nrounds = selected_trees,
    objective = "reg:squarederror",
    eval_metric = "rmse",
    early_stopping_rounds = 150,
    nfold = 10,
    max_depth = selected_depth,
    min_child_weight = selected_min_child,
    eta = selected_eta,
    gamma = selected_gamma,
    print_every_n = 15
  )

  # initialise the best iteration
  best_iteration <- 0

  # First, check if best_iteration is valid
  if (is.null(
    m_xgb_untuned$best_iteration
  ) ||
    m_xgb_untuned$best_iteration < 1) {
    cat(paste0(
      "Warning: No valid best_iteration found.",
      " Using last iteration values instead.\n"
    ))
    # Use the last iteration if best_iteration is not valid
    best_iteration <- nrow(m_xgb_untuned$evaluation_log)
  } else {
    # Ensure that the best_iteration does not exceed the number of rows logged
    if (m_xgb_untuned$best_iteration > nrow(m_xgb_untuned$evaluation_log)) {
      cat(paste0(
        "Warning: best_iteration exceeds the number of rows in evaluation_log.",
        " Adjusting to maximum available.\n"
      ))
      best_iteration <- nrow(m_xgb_untuned$evaluation_log)
    } else {
      best_iteration <- m_xgb_untuned$best_iteration
    }


    best_rmse_trained <- if (best_iteration > 0) {
      m_xgb_untuned$evaluation_log$train_rmse_mean[best_iteration]
    } else {
      NA # Or appropriate default/error value
    }

    best_rmse_test <- if (best_iteration > 0) {
      m_xgb_untuned$evaluation_log$test_rmse_mean[best_iteration]
    } else {
      NA # Or appropriate default/error value
    }

    cat(paste0(
      "The best iteration occurs with tree #: ",
      best_iteration, "\n\n"
    ))

    # Add the hyperparameters and metrics from the best iteration for the current grid iteration to the dataframe
    aneu_reg_metrics_df <- rbind(aneu_reg_metrics_df, data.frame(
      RNA_set = selected_rna_set,s
      Trees = best_iteration,
      Feature = selected_feature,
      Max_depth = selected_depth,
      Child_weight = selected_min_child,
      Eta = selected_eta,
      Gamma = selected_gamma,
      Trained_RMSE = best_rmse_trained,
      Test_RMSE = best_rmse_test,
      Seed = selected_seed
    ))
  }
}


name <- paste0(
  "categorical/",
  selected_feature, "_",
  index, "_", ".csv"
) %>%
  str_replace_all(" ", "_") %>%
  str_replace_all(":", "_")

# Save the metrics for the current feature
write.csv(
  aneu_reg_metrics_df,
  file = name,
  row.names = FALSE
)

cat(paste0("\n Completed processing for index: ", index, "\n"))
