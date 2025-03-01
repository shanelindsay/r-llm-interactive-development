# Sample Project: Income-Expense Analysis

This is a sample project structure for LLM-driven interactive R development. It demonstrates the recommended organization for a data analysis project using the R-PowerShell integration tools.

## Project Structure

- `data/`: Raw and processed data files
- `scripts/`: R scripts developed during the analysis
- `logs/`: Execution logs and console output
- `r_tools/`: R-PowerShell integration tools
- `llm_artifacts/`: LLM-specific content
  - `feedback/`: Notes on LLM performance
- `outputs/`: Analysis outputs
  - `figures/`: Generated plots
  - `tables/`: Generated tables
  - `models/`: Saved model objects
- `reports/`: Analysis RMarkdown reports
- `manuscript/`: Final publication documents

## Getting Started

1. Copy the R-PowerShell integration tools to the `r_tools/` directory
2. Start the R server with this project as the working directory:
   ```powershell
   ./r_tools/rserver.ps1 start -WorkingDirectory "path/to/this/project"
   ```
3. Begin interactive development with the LLM assistant

## Analysis Workflow

This sample project is set up for analysing the relationship between income, expenses, and outcomes. The analysis will follow these steps:

1. Data cleaning and exploration
2. Basic correlation analysis
3. Regression modelling with interactions
4. Results visualization
5. Analysis report creation
6. Manuscript preparation

## Meta Logging

Use the `llm_artifacts/meta_log.md` file to track high-level progress, document decisions, and maintain context between sessions.

## Two-Stage RMarkdown Process

1. First create analysis reports in the `reports/` directory to verify results
2. Once verified, create publication-focused documents in the `manuscript/` directory 