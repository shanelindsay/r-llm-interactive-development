# LLM-Driven Interactive R Development Guide

This guide outlines a workflow for using Large Language Models (LLMs) as agents for interactive R development, leveraging a command-line interface and a persistent R server. This approach focuses on iterative development that eventually leads to reproducible RMarkdown documents.

## Core Philosophy

The LLM-driven interactive development approach follows these principles:

1. **Interactive Exploration**: Use a persistent R server to maintain state while exploring data and developing code
2. **Piecemeal Development**: Build code chunk by chunk, testing each component as you go
3. **Continuous Documentation**: Log all outputs and decisions for debugging and reproducibility
4. **Iterative Refinement**: Gradually improve code based on immediate feedback
5. **LLM as Development Partner**: Leverage LLMs to suggest code, explain errors, and document analyses
6. **Seamless Transition**: Move smoothly from exploratory analysis to polished RMarkdown reports

## Prerequisites

- R (>= 3.5.0)
- R packages: httpuv, jsonlite, rmarkdown, knitr (and any analysis-specific packages)
- A command-line interface (PowerShell, Bash, etc.)
- A persistent R server setup (provided in this repository)
- An LLM assistant with access to the command line

## Server-Based Architecture

Instead of one-off R script executions, this approach uses a persistent R server that:

1. Runs continuously in the background
2. Maintains state (variables, data, models) between commands
3. Communicates with the command line via HTTP/JSON
4. Supports interactive debugging and exploration
5. Facilitates logging and output capture

## Recommended Project Organization

Organize your work in a clear project structure:

```
ProjectName/
├── data/                  # Raw and processed data
├── scripts/               # R scripts built interactively
│   ├── exploration.R      # Exploratory analysis
│   ├── data_prep.R        # Data preparation 
│   ├── modeling.R         # Statistical modeling
│   └── visualization.R    # Data visualization
├── logs/                  # Execution logs and console output
│   ├── session_log.txt    # Log of commands and outputs
│   └── sink_output.txt    # R console output via sink()
├── r_tools/               # R-PowerShell integration tools
│   ├── r_json_server.R    # R HTTP server
│   ├── r_json_client.ps1  # PowerShell client functions
│   ├── rserver.ps1        # Server management script
│   ├── r_command.ps1      # Command execution wrapper
│   ├── start_server.bat   # Simple server starter
│   └── check_packages.R   # Package verification script
├── llm_artifacts/         # LLM-specific content
│   ├── meta_log.md        # Development plan and progress tracking
│   └── feedback/          # Notes on LLM performance and suggestions
├── outputs/               # Analysis outputs
│   ├── figures/           # Generated plots
│   ├── tables/            # Generated tables
│   └── models/            # Saved models
├── reports/               # Analysis RMarkdown reports
│   ├── analysis.Rmd       # Analysis document
│   └── analysis.html      # Rendered HTML report
└── manuscript/            # Final publication documents
    ├── manuscript.Rmd     # Final manuscript for publication
    └── manuscript.pdf     # Rendered manuscript
```

## The Two-Stage RMarkdown Process

This approach distinguishes between two distinct RMarkdown processes:

1. **Analysis RMarkdown (in `reports/`)**: Documents focused on generating, exploring, and validating results
   - Created during the iterative development process
   - Contains detailed code, diagnostics, and exploratory visualizations
   - Primarily for analytical purposes and verification of findings
   - Should be examined thoroughly before proceeding to manuscript writing

2. **Manuscript RMarkdown (in `manuscript/`)**: Documents focused on final publication or reporting
   - Created only after analysis results have been verified and understood
   - More selective about what code and outputs to show
   - Emphasizes narrative, interpretation, and publication-quality visuals
   - May cite or reference findings from analysis reports

This two-stage process ensures that you first verify your results before committing to writing them up formally.

## Meta Logging for LLM-Driven Development

The `llm_artifacts/meta_log.md` file serves as a high-level record of the analysis process:

1. **Development Plan**: Initial goals, research questions, and planned analyses
2. **Session Summaries**: Brief records of each development session with the LLM
3. **Decision Points**: Documentation of key analytical decisions and their rationale
4. **Progress Tracking**: Notes on completed stages and remaining tasks
5. **Challenges and Solutions**: Record of encountered issues and how they were addressed

Example meta log entry:
```markdown
## 2023-10-15: Initial Analysis Planning

**Goals for this project:**
- Determine relationship between income and outcome variables
- Assess how expenses moderate this relationship
- Create publication-ready visualizations

**Planned Analysis Steps:**
1. Data cleaning and exploration 
2. Basic correlation analysis 
3. Regression modelling with interactions 
4. Results visualization 
5. Analysis report 
6. Manuscript draft 

**Decisions made:**
- Will use listwise deletion for missing values due to low rate (<5%)
- Will test for non-linear relationships in initial exploration
- Will create both technical and publication-quality visualizations

**Next session:** Begin data cleaning and exploration
```

The meta log provides a high-level overview that helps maintain focus during extended analyses, preserve context between sessions, and document the evolution of the project.

## The LLM-Driven Workflow

### 1. Setup Phase

Begin by setting up the project environment and starting the R server:

```powershell
# Create project structure (command varies by shell)
mkdir -p ProjectName/{data,scripts,logs,r_tools,llm_artifacts/{prompts,chat_logs,feedback},outputs/{figures,tables,models},reports,manuscript}

# Copy server tools to r_tools directory
cp /path/to/tools/* ProjectName/r_tools/

# Start the R server with your project directory as the working directory
./r_tools/rserver.ps1 start -WorkingDirectory "path/to/ProjectName"

# Initialize meta logging
New-Item -Path "llm_artifacts/meta_log.md" -ItemType File -Force
Add-Content -Path "llm_artifacts/meta_log.md" -Value @"
# Project Meta Log

## $(Get-Date -Format "yyyy-MM-dd"): Project Initialization

**Project Goals:**
- [List your primary research questions]

**Planned Analysis:**
- [Outline your analysis plan]

**Initial Decisions:**
- [Document any initial decisions]

**Next Steps:**
- Begin data exploration
"@
```

The LLM should:
- Help set up the project structure
- Ensure the R server is running with the correct working directory
- Initialize logging with `sink()` for capturing console output
- Start the meta log to track high-level progress

Example (using PowerShell with included R-JSON server):
```powershell
# LLM executes this to start logging in R
./r_tools/r_command.ps1 'sink("logs/session_log.txt", split=TRUE); cat("=== Session started:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "===\n")'
```

### 2. Interactive Exploration

The LLM guides you through data exploration, executing small code chunks and observing the results:

```powershell
# Load data
./r_tools/r_command.ps1 'data <- read.csv("data/dataset.csv"); str(data)'

# Examine data structure and summary
./r_tools/r_command.ps1 'summary(data)'

# Test transformations
./r_tools/r_command.ps1 'data_clean <- na.omit(data); data_clean$new_var <- data_clean$var1/data_clean$var2'
```

The LLM should:
- Execute small, manageable chunks of code
- Examine outputs thoroughly before proceeding
- Test multiple approaches when appropriate
- Document findings and decisions
- Track successful code for later inclusion in scripts

Example of LLM reasoning:
```
I notice that the data has missing values in the 'income' column. Let me try two approaches:
1. Remove rows with NA values
2. Impute missing values with the median

Let's test both and compare results:
```

### 3. Capturing Working Code

As chunks of code prove successful, the LLM saves them to script files:

```powershell
# Append successful code to script file
Add-Content -Path "scripts/data_prep.R" -Value @"
# Data cleaning operations
# Added on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Load data
data <- read.csv("data/dataset.csv")

# Remove missing values
data_clean <- na.omit(data)

# Create derived variables
data_clean$income_ratio <- data_clean$income / data_clean$expenses
"@
```

The LLM should:
- Document each code chunk with timestamps and explanations
- Organize code logically (data loading, cleaning, analysis, visualization)
- Structure scripts to reflect the analysis workflow
- Use consistent naming conventions and style

### 4. Interactive Debugging

When errors occur, the LLM assists with debugging:

```powershell
# Run code that produces an error
./r_tools/r_command.ps1 'result <- lm(y ~ x + group, data=data_clean)'
# Error: object 'y' not found

# LLM examines the data to identify the issue
./r_tools/r_command.ps1 'names(data_clean)'
# [1] "id" "income" "expenses" "income_ratio" "outcome"

# LLM corrects the model specification
./r_tools/r_command.ps1 'result <- lm(outcome ~ income + expenses, data=data_clean)'
```

The LLM should:
- Interpret error messages accurately
- Check data structures and variable names
- Test alternative approaches
- Document both errors and solutions
- Explain reasoning behind debugging steps

### 5. Using sink() for Logging

The LLM implements comprehensive logging using sink():

```powershell
# LLM implements function for experimental code with logging
./r_tools/r_command.ps1 '
try_code <- function(code_string, log_file="logs/experiments.log") {
  sink(log_file, append=TRUE)
  cat("\n=== EXPERIMENT:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "===\n")
  cat("CODE:\n", code_string, "\n\n")
  cat("RESULT:\n")
  
  result <- tryCatch({
    expr <- parse(text=code_string)
    eval(expr)
  }, error=function(e) {
    cat("ERROR:", e$message, "\n")
    return(NULL)
  })
  
  cat("\n=== END EXPERIMENT ===\n\n")
  sink()
  return(result)
}'

# Use the function to test code
./r_tools/r_command.ps1 'try_code("model <- lm(outcome ~ income * expenses, data=data_clean); summary(model)")'
```

The LLM should:
- Set up appropriate logging mechanisms
- Capture both successful and failed execution results
- Document decision points and alternative approaches
- Create helper functions for experiment tracking
- Ensure logs are human-readable for future reference

### 6. Building Up the Analysis

The LLM guides the user through building a complete analysis step by step:

```powershell
# Execute data preparation script
./r_tools/r_command.ps1 'source("scripts/data_prep.R")'

# Develop and execute modelling code
./r_tools/r_command.ps1 'model <- lm(outcome ~ income + expenses + income:expenses, data=data_clean)'
./r_tools/r_command.ps1 'model_summary <- summary(model)'
./r_tools/r_command.ps1 'anova(model)'

# Visualize results
./r_tools/r_command.ps1 'library(ggplot2)'
./r_tools/r_command.ps1 'p <- ggplot(data_clean, aes(x=income, y=outcome, colour=expenses>median(expenses))) +
  geom_point() +
  geom_smooth(method="lm") +
  labs(title="Outcome vs Income by Expense Level")'
./r_tools/r_command.ps1 'ggsave("outputs/figures/income_outcome_plot.png", p, width=8, height=6)'
```

The LLM should:
- Develop the analysis in logical stages
- Create appropriate visualizations
- Save outputs systematically (tables, figures, models)
- Ensure reproducibility at each step
- Document the statistical reasoning

### 7. Creating an Analysis RMarkdown Report

Once the analysis is taking shape, the LLM creates an Analysis RMarkdown to verify results:

```powershell
# Create Analysis RMarkdown template
New-Item -Path "reports/analysis.Rmd" -ItemType File -Force
Add-Content -Path "reports/analysis.Rmd" -Value @"
---
title: "Analysis Report: Income-Expense Study"
author: "LLM & Human Collaboration"
date: "`r format(Sys.time(), '%d %B, %Y')`"
output: 
  html_document:
    toc: true
    toc_float: true
    code_folding: show
---

## Introduction

This is an analysis report to explore and validate our findings on the relationship between income, expenses, and outcomes.

## Data Preparation

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, warning = TRUE, message = TRUE)
```

```{r data-prep}
# Load the prepared data
source("../scripts/data_prep.R")

# Display summary statistics
summary(data_clean)
```

## Statistical Analysis

```{r modelling}
# Fit regression model
model <- lm(outcome ~ income + expenses + income:expenses, data=data_clean)
summary(model)

# Model diagnostics
par(mfrow=c(2,2))
plot(model)
```

## Visualization

```{r visualization, fig.width=8, fig.height=6}
library(ggplot2)
ggplot(data_clean, aes(x=income, y=outcome, colour=expenses>median(expenses))) +
  geom_point() +
  geom_smooth(method="lm") +
  labs(title="Outcome vs Income by Expense Level")
```

## Results Summary

Key findings from the analysis:

- Summary of coefficients
- Interpretation of interaction effects
- Model fit statistics
- Diagnostic observations

"@

# Render the analysis report
./r_tools/r_command.ps1 'rmarkdown::render("reports/analysis.Rmd")'
```

The LLM should:
- Create a well-structured analysis RMarkdown document
- Include comprehensive code chunks for validation
- Show diagnostic information that might not appear in final manuscript
- Enable thorough verification of results

### 8. Examining Analysis Results 

After rendering the analysis report, the LLM and user should:
- Open and examine the HTML output
- Verify that results are valid and diagnostics are acceptable
- Identify key findings to highlight in the manuscript
- Note any additional analyses needed

### 9. Creating the Manuscript RMarkdown

Once results are verified, the LLM creates a manuscript RMarkdown for formal write-up:

```powershell
# Create Manuscript RMarkdown
New-Item -Path "manuscript/manuscript.Rmd" -ItemType File -Force
Add-Content -Path "manuscript/manuscript.Rmd" -Value @"
---
title: "The Relationship Between Income, Expenses, and Outcomes"
author: "Research Team"
date: "`r format(Sys.time(), '%d %B, %Y')`"
output:
  pdf_document:
    toc: true
    number_sections: true
bibliography: references.bib
csl: apa.csl
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
# Load required packages silently
library(tidyverse)
library(knitr)
library(kableExtra)
# Load analysis results
source("../scripts/data_prep.R")
source("../scripts/modelling.R")
```

# Introduction

This study examines the relationship between income, expenses, and various outcome measures. Previous research has indicated a complex interaction between these factors [@author2020].

# Methods

## Data Collection

Data were collected from [describe data source] between [dates]. The dataset includes [n] observations with complete information on income, expenses, and outcome measures.

## Statistical Analysis

Linear regression models were used to assess the relationship between income, expenses, and outcomes. Interaction effects were tested to determine whether the relationship between income and outcomes varied as a function of expense level.

# Results

## Descriptive Statistics

```{r descriptive-table}
# Create a publication-quality table of descriptive statistics
desc_stats <- data_clean %>%
  summarise(
    Mean_Income = mean(income),
    SD_Income = sd(income),
    Mean_Expenses = mean(expenses),
    SD_Expenses = sd(expenses),
    Mean_Outcome = mean(outcome),
    SD_Outcome = sd(outcome)
  )

kable(desc_stats, digits = 2, caption = "Descriptive Statistics") %>%
  kable_styling(latex_options = "hold_position")
```

## Regression Analysis

```{r model-results, fig.width=6, fig.height=4}
# Create publication-quality plot
ggplot(data_clean, aes(x=income, y=outcome, colour=expenses>median(expenses))) +
  geom_point(alpha = 0.7) +
  geom_smooth(method="lm", se=TRUE) +
  labs(
    title = "",
    x = "Income",
    y = "Outcome",
    colour = "High Expenses"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
```

Table \@ref(tab:model-coef) presents the regression coefficients.

```{r model-coef}
# Extract and format model coefficients
coef_table <- as.data.frame(summary(model)$coefficients)
coef_table$term <- rownames(coef_table)
rownames(coef_table) <- NULL
coef_table <- coef_table %>% 
  select(term, Estimate, `Std. Error`, `t value`, `Pr(>|t|)`)

kable(coef_table, digits = 3, 
      caption = "Regression Model Coefficients",
      col.names = c("Term", "Estimate", "Std. Error", "t value", "p value")) %>%
  kable_styling(latex_options = c("hold_position", "scale_down"))
```

# Discussion

The regression analysis revealed a significant interaction between income and expenses in predicting outcomes. Specifically, the relationship between income and outcomes was stronger for individuals with higher expenses.

# Conclusion

These findings suggest that [key conclusion]. Future research should explore [recommendations].

# References
"@

# Create bibliography file
New-Item -Path "manuscript/references.bib" -ItemType File -Force
Add-Content -Path "manuscript/references.bib" -Value @"
@article{author2020,
  title={Title of the paper},
  author={Author, A. and Author, B.},
  journal={Journal Name},
  volume={10},
  number={2},
  pages={100--110},
  year={2020},
  publisher={Publisher}
}
"@

# Download APA CSL file if needed
./r_tools/r_command.ps1 'download.file("https://raw.githubusercontent.com/citation-style-language/styles/master/apa.csl", "manuscript/apa.csl")'

# Render the manuscript
./r_tools/r_command.ps1 'rmarkdown::render("manuscript/manuscript.Rmd")'
```

The LLM should:
- Create a publication-focused manuscript RMarkdown
- Hide most code chunks in the output
- Create publication-quality tables and figures
- Include proper citations and references
- Structure the document according to academic standards
- Remove debug/diagnostic content not suitable for publication

## Benefits of LLM-Driven Interactive Development

1. **Rapid Iteration**: Test ideas quickly with immediate feedback
2. **Comprehensive Documentation**: Automated logging and explanation of reasoning
3. **Transparent Debugging**: Clear tracking of errors and solutions
4. **Educational Value**: Learn R concepts and techniques during development
5. **Reproducible Research**: End result is a fully documented, reproducible analysis
6. **Efficiency**: LLM can handle boilerplate code and documentation
7. **Flexibility**: Adapt the approach to different shells, operating systems, and R interfaces

## Limitations and Considerations

1. **State Dependency**: Commands rely on previous state, which can make debugging challenging
2. **Error Propagation**: Early errors can cascade through the analysis
3. **Context Window Limitations**: LLMs may lose track of the full session history
4. **Security Considerations**: Be careful about executing untrusted code
5. **Command-Line Variations**: Syntax differs between shells (PowerShell, Bash, etc.)

## Command Reference

For Windows PowerShell (using included tools):

```powershell
# Start R server
.\r_tools/rserver.ps1 start

# Execute R command
.\r_tools/r_command.ps1 "summary(mtcars)"

# Check server status
.\r_tools/rserver.ps1 status

# Shutdown server
.\r_tools/rserver.ps1 shutdown
```

## Conclusion

The LLM-driven interactive development approach combines the flexibility of interactive exploration with the rigour of reproducible research. By using a persistent R server and a command-line interface, it enables iterative development guided by an LLM assistant, culminating in well-documented RMarkdown reports. This approach is particularly valuable for complex analyses where the path forward evolves as insights emerge from the data. 