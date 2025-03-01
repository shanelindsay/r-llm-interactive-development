# R-LLM Interactive Development

## Overview

This project provides tools and workflows for integrating Large Language Models (LLMs) with R programming through a cross-platform approach. It enables interactive development, data analysis, and reporting by leveraging the capabilities of LLMs whilst maintaining the statistical power and data manipulation strengths of R. The tools support both Windows (via PowerShell) and Unix/Linux/macOS (via Bash) environments.

## Repository Structure

This repository is organised into three main components:

1. **R Integration Tools**: A set of platform-specific tools that enable communication between the operating system and R via HTTP/JSON
2. **Templates**: Starter templates for creating new projects with the recommended directory structure
3. **Documentation**: Comprehensive guides for using LLMs in interactive R development

> **Note:** The repository structure (with tools, templates, docs) is separate from the project structure (with data, scripts, outputs). Project-level directories exist only within the template and in actual projects created from the template. See [Repository Structure Guide](docs/repository_structure.md) for more details.

### Cross-Platform Support

This toolkit provides full cross-platform support for both Windows and Unix-like operating systems (Linux/macOS). Each platform has a complete set of tools with equivalent functionality, using appropriate scripting languages:

- **Windows**: PowerShell and Batch scripts
- **Unix/Linux/macOS**: Bash shell scripts

For detailed information about the cross-platform implementation, see [Cross-Platform Support](docs/cross_platform.md).

### Tools Directory

The `tools/` directory contains the R integration tools organised by platform:

- **Core Tools** (Platform-neutral):
  - `r_json_server.R` - Persistent HTTP server that executes R commands and returns results in JSON format
  - `check_packages.R` - Script to verify and install required R packages

- **Windows Tools** (PowerShell):
  - `r_json_client.ps1` - PowerShell functions for communicating with the R server
  - `rserver.ps1` - Unified script for managing the R server (start, execute, status, shutdown)
  - `r_command.ps1` - Simple wrapper for executing R commands
  - `start_server.bat` - Batch file for starting the R server

- **Unix Tools** (Bash):
  - `r_json_client.sh` - Bash functions for communicating with the R server
  - `rserver.sh` - Unified script for managing the R server (start, execute, status, shutdown)
  - `r_command.sh` - Simple wrapper for executing R commands
  - `start_server.sh` - Shell script for starting the R server

For detailed information about these tools, see [docs/tools.md](docs/tools.md).

### Templates Directory

The `templates/` directory contains project templates you can use to start a new analysis:

- `templates/basic_project/`: A complete project template with the recommended directory structure for LLM-driven R development

To create a new project from the template, use one of the included scripts:

#### For Windows:

```powershell
# Create a new project named "MyAnalysis" in the specified directory
.\new_project.ps1 -ProjectName "MyAnalysis" -ProjectPath "C:/Users/YourName/Projects"
```

#### For Unix/Linux/macOS:

```bash
# Create a new project named "MyAnalysis" in the specified directory
./new_project.sh "MyAnalysis" "/home/username/Projects"
```

### Documentation and Guides

- `docs/tools.md`: Detailed documentation of the R integration tools
- `docs/guide.md`: Comprehensive guide to LLM-driven interactive R development
- `docs/workflow.md`: Step-by-step workflow examples
- `docs/repository_structure.md`: Explanation of the repository organization

## Getting Started

### Prerequisites

- R version 4.0.0 or higher
- For Windows: PowerShell 5.1+
- For Unix/Linux/macOS: Bash shell
- Required R packages: jsonlite, httpuv

### Installation

1. Clone this repository
2. Install required R packages:
   ```r
   install.packages(c("jsonlite", "httpuv"))
   ```

### Creating a New Project

#### Windows:

```powershell
# Create a new project
.\new_project.ps1 -ProjectName "MyAnalysis" -ProjectPath "C:/Users/YourName/Projects"

# Navigate to the project
cd C:/Users/YourName/Projects/MyAnalysis

# Start the R server
.\r_tools\rserver.ps1 start
```

#### Unix/Linux/macOS:

```bash
# Create a new project
./new_project.sh "MyAnalysis" "/home/username/Projects"

# Navigate to the project
cd /home/username/Projects/MyAnalysis

# Start the R server
./r_tools/rserver.sh start
```

### Quick Command Reference

#### Windows (PowerShell):

```powershell
# Execute an R command
.\r_tools\r_command.ps1 "summary(mtcars)"

# Check server status
.\r_tools\rserver.ps1 status

# Stop the server when finished
.\r_tools\rserver.ps1 stop
```

#### Unix/Linux/macOS (Bash):

```bash
# Execute an R command
./r_tools/r_command.sh "summary(mtcars)"

# Check server status
./r_tools/rserver.sh status

# Stop the server when finished
./r_tools/rserver.sh stop
```

## Project Template Structure 

When you create a new project using the template, it will have the following structure:

```
MyAnalysis/
├── data/           # Raw and processed data files
├── scripts/        # R scripts developed during analysis
├── logs/           # Execution logs and console output
├── r_tools/        # R integration tools (copied from this repo, platform-specific)
├── llm_artifacts/  # LLM-specific content
│   ├── feedback/   # Notes on LLM performance
│   └── meta_log.md # Project tracking and context for LLM sessions
├── outputs/        # Analysis outputs
│   ├── figures/    # Generated plots
│   ├── tables/     # Generated tables
│   └── models/     # Saved model objects
├── reports/        # Analysis RMarkdown reports
├── manuscript/     # Final publication documents
└── README.md       # Project description and instructions
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.