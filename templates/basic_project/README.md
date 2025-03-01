# Project Name

This is an R project using the LLM-driven interactive development approach.

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

1. Replace this README with a description of your project
2. Copy the R-PowerShell integration tools to the `r_tools/` directory
3. Update the meta log with your project details
4. Start the R server with this project as the working directory:
   ```powershell
   ./r_tools/rserver.ps1 start -WorkingDirectory "path/to/this/project"
   ```
5. Begin interactive development with the LLM assistant

## Meta Logging

Use the `llm_artifacts/meta_log.md` file to track high-level progress, document decisions, and maintain context between sessions.

## Two-Stage RMarkdown Process

1. First create analysis reports in the `reports/` directory to verify results
2. Once verified, create publication-focused documents in the `manuscript/` directory 