# Income-Expense Analysis: Data Preparation
# This script prepares the raw income and expense data for analysis

# Load required packages
library(tidyverse)
library(lubridate)
library(janitor)

# Set seed for reproducibility
set.seed(42)

# Create sample data directory if it doesn't exist
if (!dir.exists("data")) {
  dir.create("data")
}

# Generate synthetic income-expense data
# This would normally be replaced with actual data loading
generate_synthetic_data <- function(n_participants = 500) {
  # Create income brackets
  income_levels <- c("Low", "Medium-Low", "Medium", "Medium-High", "High")
  income_ranges <- list(
    "Low" = c(15000, 30000),
    "Medium-Low" = c(30001, 50000),
    "Medium" = c(50001, 75000),
    "Medium-High" = c(75001, 100000),
    "High" = c(100001, 200000)
  )
  
  # Generate participant data
  participants <- tibble(
    participant_id = paste0("P", str_pad(1:n_participants, 4, pad = "0")),
    age = sample(18:75, n_participants, replace = TRUE),
    gender = sample(c("Male", "Female", "Non-binary"), n_participants, 
                   replace = TRUE, prob = c(0.48, 0.48, 0.04)),
    education = sample(c("High School", "Some College", "Bachelor's", "Master's", "Doctorate"),
                      n_participants, replace = TRUE),
    income_bracket = sample(income_levels, n_participants, replace = TRUE),
    household_size = sample(1:6, n_participants, replace = TRUE, 
                           prob = c(0.2, 0.3, 0.25, 0.15, 0.07, 0.03))
  )
  
  # Add actual income based on brackets
  participants <- participants %>%
    rowwise() %>%
    mutate(
      annual_income = round(runif(1, 
                                 income_ranges[[income_bracket]][1],
                                 income_ranges[[income_bracket]][2]), -2)
    ) %>%
    ungroup()
  
  # Return the dataset
  return(participants)
}

# Generate expense data for each participant
generate_expense_data <- function(participants) {
  # Define expense categories
  expense_categories <- c("Housing", "Food", "Transportation", "Healthcare", 
                         "Entertainment", "Education", "Savings", "Other")
  
  # Base expense proportions by income bracket
  base_proportions <- list(
    "Low" = c(0.45, 0.20, 0.15, 0.10, 0.05, 0.02, 0.01, 0.02),
    "Medium-Low" = c(0.40, 0.18, 0.15, 0.08, 0.07, 0.03, 0.05, 0.04),
    "Medium" = c(0.35, 0.15, 0.12, 0.08, 0.08, 0.05, 0.12, 0.05),
    "Medium-High" = c(0.30, 0.12, 0.10, 0.07, 0.10, 0.06, 0.20, 0.05),
    "High" = c(0.25, 0.10, 0.08, 0.05, 0.12, 0.05, 0.30, 0.05)
  )
  
  # Create empty expenses dataframe
  expenses <- tibble()
  
  # Generate expenses for each participant
  for (i in 1:nrow(participants)) {
    p <- participants[i, ]
    bracket <- p$income_bracket
    income <- p$annual_income
    
    # Get base proportions for this income bracket
    props <- base_proportions[[bracket]]
    
    # Add some random variation
    props <- pmax(0.01, props + rnorm(length(props), 0, 0.03))
    props <- props / sum(props)
    
    # Calculate monthly expenses
    monthly_income <- income / 12
    monthly_expenses <- props * monthly_income
    
    # Create expense entries
    for (j in 1:length(expense_categories)) {
      # Add some month-to-month variation
      for (month in 1:12) {
        variation <- rnorm(1, 1, 0.1)
        expenses <- bind_rows(expenses, tibble(
          participant_id = p$participant_id,
          month = month,
          category = expense_categories[j],
          amount = round(monthly_expenses[j] * variation, 2)
        ))
      }
    }
  }
  
  return(expenses)
}

# Calculate financial outcomes
calculate_outcomes <- function(participants, expenses) {
  # Aggregate expenses by participant
  total_expenses <- expenses %>%
    group_by(participant_id) %>%
    summarise(total_annual_expense = sum(amount))
  
  # Join with participants and calculate outcomes
  outcomes <- participants %>%
    left_join(total_expenses, by = "participant_id") %>%
    mutate(
      savings_rate = (annual_income - total_annual_expense) / annual_income,
      financial_stress = case_when(
        savings_rate < 0 ~ "High",
        savings_rate < 0.1 ~ "Medium",
        savings_rate < 0.2 ~ "Low",
        TRUE ~ "Minimal"
      ),
      debt_risk = case_when(
        savings_rate < -0.1 ~ "Severe",
        savings_rate < 0 ~ "High",
        savings_rate < 0.05 ~ "Moderate",
        savings_rate < 0.15 ~ "Low",
        TRUE ~ "Minimal"
      )
    )
  
  return(outcomes)
}

# Main execution
message("Generating synthetic participant data...")
participants_df <- generate_synthetic_data(500)

message("Generating expense data...")
expenses_df <- generate_expense_data(participants_df)

message("Calculating financial outcomes...")
outcomes_df <- calculate_outcomes(participants_df, expenses_df)

# Save the datasets
message("Saving datasets to data directory...")
write_csv(participants_df, "data/participants.csv")
write_csv(expenses_df, "data/expenses.csv")
write_csv(outcomes_df, "data/outcomes.csv")

# Create a data dictionary
data_dictionary <- tribble(
  ~dataset, ~variable, ~description, ~type,
  "participants", "participant_id", "Unique identifier for each participant", "character",
  "participants", "age", "Age in years", "integer",
  "participants", "gender", "Self-reported gender", "character",
  "participants", "education", "Highest level of education completed", "character",
  "participants", "income_bracket", "Income category", "character",
  "participants", "household_size", "Number of people in household", "integer",
  "participants", "annual_income", "Annual income in dollars", "numeric",
  "expenses", "participant_id", "Unique identifier for each participant", "character",
  "expenses", "month", "Month number (1-12)", "integer",
  "expenses", "category", "Expense category", "character",
  "expenses", "amount", "Monthly expense amount in dollars", "numeric",
  "outcomes", "participant_id", "Unique identifier for each participant", "character",
  "outcomes", "total_annual_expense", "Sum of all expenses for the year", "numeric",
  "outcomes", "savings_rate", "Proportion of income saved", "numeric",
  "outcomes", "financial_stress", "Categorized level of financial stress", "character",
  "outcomes", "debt_risk", "Categorized risk of debt", "character"
)

write_csv(data_dictionary, "data/data_dictionary.csv")

message("Data preparation complete!")

# Summary statistics
participants_summary <- participants_df %>%
  group_by(income_bracket) %>%
  summarise(
    count = n(),
    mean_income = mean(annual_income),
    mean_household_size = mean(household_size)
  )

print(participants_summary)

# Preview the first few rows of each dataset
message("\nParticipants data preview:")
print(head(participants_df))

message("\nExpenses data preview:")
print(head(expenses_df))

message("\nOutcomes data preview:")
print(head(outcomes_df)) 