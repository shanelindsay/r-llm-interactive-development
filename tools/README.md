# R-LLM Integration Tools

This directory contains tools for integrating R with Large Language Models (LLMs) through a variety of client-side scripts. The tools are organized into subdirectories based on platform compatibility:

## Directory Structure

- `/core/` - Platform-neutral R tools that work on any operating system that supports R
- `/windows/` - Windows-specific PowerShell and batch scripts
- `/unix/` - Unix/Linux/macOS-specific Bash scripts

## Core Tools

These are the core R tools that work on any platform:

- `r_json_server.R` - The main R JSON HTTP server that handles requests from client scripts
- `check_packages.R` - Utility script to check and install required R packages

## Windows Tools

Windows-specific client tools for PowerShell:

- `r_json_client.ps1` - PowerShell client for communicating with the R JSON server
- `rserver.ps1` - PowerShell script for managing the R server (start, stop, status)
- `r_command.ps1` - Simple wrapper for executing R commands
- `start_server.bat` - Batch file for quick server startup

## Unix Tools

Unix/Linux/macOS-specific client tools:

- `r_json_client.sh` - Bash client for communicating with the R JSON server
- `rserver.sh` - Bash script for managing the R server (start, stop, status)
- `r_command.sh` - Simple wrapper for executing R commands
- `start_server.sh` - Bash script for quick server startup

## Usage

### Platform Detection

The tools are designed to be used with platform detection:

```powershell
# For Windows (PowerShell)
.\tools\windows\r_command.ps1 "print('Hello from R')"
```

```bash
# For Unix/Linux/macOS (Bash)
./tools/unix/r_command.sh "print('Hello from R')"
```

### Common Operations

Across both platforms, the tools provide these common operations:

1. Starting the R server:
   - Windows: `.\tools\windows\rserver.ps1 start`
   - Unix: `./tools/unix/rserver.sh start`

2. Executing R code:
   - Windows: `.\tools\windows\r_command.ps1 "library(dplyr); mtcars %>% head()"`
   - Unix: `./tools/unix/r_command.sh "library(dplyr); mtcars %>% head()"`

3. Checking server status:
   - Windows: `.\tools\windows\rserver.ps1 status`
   - Unix: `./tools/unix/rserver.sh status`

4. Stopping the server:
   - Windows: `.\tools\windows\rserver.ps1 stop`
   - Unix: `./tools/unix/rserver.sh stop`

## New Project Setup

When creating a new project with the `new_project.ps1` or `new_project.sh` script, the appropriate platform-specific tools will be copied to your project's `r_tools` directory. 