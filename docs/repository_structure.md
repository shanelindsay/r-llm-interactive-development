# Repository Structure Guide

This document explains the organization of the R-LLM Interactive Development repository. The repository is structured to clearly separate repository-level files from project-level files.

## Repository Organisation

The repository has the following main components:

```
r-llm-interactive-development/
├── docs/                 # Documentation
│   ├── tools.md          # Tool documentation
│   ├── guide.md          # General guide
│   └── repository_structure.md  # This file
├── examples/             # Example projects
│   └── sample_project/   # A complete sample project
├── templates/            # Project templates
│   └── basic_project/    # Basic project template
├── tools/                # R-PowerShell integration tools
├── .gitignore            # Git ignore file
├── new_project.ps1       # Script to create new projects
└── README.md             # Repository documentation
```

## Repository vs Project Files

There is an important distinction between:

1. **Repository-level directories** - These exist at the root of the repository and contain files that are part of the R-LLM Interactive Development toolkit. They include tools, documentation, and templates.

2. **Project-level directories** - These are directories that should exist in your actual analysis projects, not at the root of the repository. They are only found inside the `templates/basic_project/` directory and `examples/sample_project/` directory.

## Directory Types

### Repository Directories

Repository directories exist at the root level and include:

- `docs/`: Documentation for using the tools and workflows
- `tools/`: R-PowerShell integration tools
- `templates/`: Template structures for new projects
- `examples/`: Example projects to demonstrate usage

### Project Directories

Project directories exist only within projects created from the template, and include:

```
project_name/
├── data/           # Raw and processed data files
├── scripts/        # R scripts developed during analysis
├── logs/           # Execution logs and console output
├── r_tools/        # R-PowerShell integration tools (copied from repository)
├── llm_artifacts/  # LLM-specific content
│   ├── feedback/   # Notes on LLM performance
│   └── meta_log.md # Project tracking and context
├── outputs/        # Analysis outputs
│   ├── figures/    # Generated plots
│   ├── tables/     # Generated tables
│   └── models/     # Saved model objects
├── reports/        # Analysis RMarkdown reports
├── manuscript/     # Final publication documents
└── README.md       # Project description
```

## Creating a New Project

When you create a new project using the `new_project.ps1` script, it copies the template structure from `templates/basic_project/` to your specified location and customizes it with your project name.

This maintains a clean separation between the repository's meta-files and your actual analysis project files.

```powershell
# Create a new project
./new_project.ps1 -ProjectName "MyAnalysis" -ProjectPath "C:/Users/YourName/Projects"
```

## Why This Structure Matters

This separation ensures that:

1. The repository remains focused on providing tools and templates
2. Your projects have a consistent, recommended directory structure
3. You can easily update the tools without mixing them with your analysis files
4. The distinction between what is part of the toolkit and what is part of your analysis is clear

## Common Questions

### Why aren't project directories (data, scripts, etc.) at the repository root?

Project directories should only exist in your actual analysis projects. If they were at the repository root, it would confuse users about what is part of the toolkit versus what should be in their own projects.

### How do I get started with a new project?

Use the `new_project.ps1` script to create a new project from the template, which will set up the recommended directory structure for you. 