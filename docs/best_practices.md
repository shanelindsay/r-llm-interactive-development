# Best Practices for LLM-Driven Interactive R Development

This guide outlines best practices for effectively using the LLM-driven interactive R development workflow.

## Project Organization

1. **Follow the Standard Structure**
   - Maintain the recommended directory structure for consistency
   - Keep scripts in the `scripts/` directory
   - Save all outputs to the `outputs/` directory with appropriate subdirectories
   - Place RMarkdown reports in the `reports/` directory

2. **Use Meaningful File Names**
   - Give scripts descriptive names that reflect their purpose
   - Consider numbering scripts to indicate execution order (e.g., `01_data_prep.R`)
   - Use consistent naming conventions throughout the project

3. **For Complex Projects**
   - Consider using subdirectories within the main directories to organize by experiment or analysis type
   - Create a project-specific README to explain the structure

## File Path Management

1. **Always Use the `here()` Package**
   - Load the `here` package at the beginning of each script
   - Use `here()` for all file paths to ensure reproducibility
   - Never use absolute paths or working directory-dependent relative paths

2. **Example of Proper Path Usage**
   ```r
   library(here)
   
   # Reading data
   data <- read.csv(here("data", "raw_data.csv"))
   
   # Saving outputs
   saveRDS(model, here("outputs", "models", "linear_model.rds"))
   ggsave(here("outputs", "figures", "scatter_plot.png"), plot = p, width = 6, height = 4)
   ```

## R Server and Command-Line Interaction

1. **Start with a Clean Session**
   - Begin each analysis with a fresh R server instance
   - Use a project-specific working directory when starting the server

2. **Use Logging**
   - Initialize logging at the beginning of your session
   - Use `sink()` to capture console output
   - Consider additional logging with the `logger` package for complex projects

3. **Command Execution Best Practices**
   - Keep commands concise and focused on specific tasks
   - Use semicolons to separate multiple operations when appropriate
   - Avoid extremely long command chains that are difficult to debug

4. **Error Handling**
   - When errors occur, analyze them carefully with LLM assistance
   - Fix one error at a time rather than attempting multiple changes

## Script Development

1. **Modularize Your Analysis**
   - Create separate scripts for distinct analysis stages
   - Keep scripts focused on specific tasks or outputs
   - Use functions for repeated operations

2. **Emphasize Reproducibility**
   - Set random seeds for functions involving randomness
   - Document package versions with `sessionInfo()`
   - Consider using `renv` for package management

3. **Script Documentation**
   - Include a detailed header in each script
   - Document the purpose, inputs, and outputs
   - Add comments explaining complex operations or analytical choices

4. **Output Generation**
   - Design scripts to save all important outputs to files
   - Include metadata and timestamps with saved outputs
   - Use consistent output formats for similar types of data

## LLM Collaboration

1. **Effective LLM Prompting**
   - Be specific when asking the LLM for code
   - Clearly describe the goals and desired outputs
   - Provide context about your data and analysis needs

2. **Code Review with LLMs**
   - Have the LLM review complex code before execution
   - Ask for explanations of unfamiliar functions or approaches
   - Use the LLM to suggest optimizations or alternative methods

3. **Documentation Assistance**
   - Ask the LLM to help document code and workflows
   - Use LLM suggestions to add explanatory comments
   - Have the LLM help draft narrative sections for RMarkdown reports

4. **Learning from LLMs**
   - Ask for explanations of statistical methods or functions
   - Have the LLM explain why certain approaches are being used
   - Build your own R skills through the interactive dialogue

## RMarkdown Reporting

1. **Focus on Presentation**
   - Keep analysis code in scripts, not RMarkdown documents
   - Use RMarkdown primarily to load and present pre-computed outputs
   - Add narrative context, interpretation, and visualization

2. **Consistent Formatting**
   - Use a consistent style throughout documents
   - Consider using a custom theme or template
   - Include appropriate citations and references

3. **Report Organization**
   - Structure documents with clear sections
   - Include an executive summary or abstract
   - Provide appendices for detailed methodological information

## Version Control Integration

1. **Git Best Practices**
   - Commit frequently with descriptive messages
   - Consider using branching for experimental analyses
   - Include `.gitignore` to exclude large data files and outputs

2. **What to Commit**
   - Always commit scripts and RMarkdown files
   - Commit small, essential data files
   - Consider using Git LFS for larger files
   - Document which outputs should be regenerated rather than committed

## Security and Reproducibility

1. **Data Security**
   - Never include sensitive data in the repository
   - Consider using environment variables for sensitive paths or credentials
   - Document data access procedures separately

2. **Ensuring Full Reproducibility**
   - Include a setup script that installs all required packages
   - Document system requirements
   - Consider using containerization (e.g., Docker) for complex environments

## Scaling to Larger Projects

1. **Managing Multiple Analyses**
   - Use subdirectories to organize different experiments or analyses
   - Create a master script that can run the entire workflow
   - Consider using make-like tools (e.g., `targets` package) for complex workflows

2. **Collaboration Strategies**
   - Establish clear conventions for shared projects
   - Use branches for different team members' work
   - Consider regular code reviews among team members 