# R-PowerShell Tools for LLM-Driven Development

This document describes the R-PowerShell integration tools that enable LLM-driven interactive R development. These tools facilitate communication between PowerShell and R using HTTP/JSON, allowing for interactive development with state persistence.

## Overview of Tools

The LLM-driven interactive development approach relies on several key tools that work together in a layered architecture. These tools can be categorized by their roles in the system:

### Core Components
1. **R JSON HTTP Server** (`r_json_server.R`): A persistent HTTP server written in R that processes commands and returns results in JSON format

### API Layer
2. **PowerShell Client** (`r_json_client.ps1`): PowerShell functions for communicating with the R server

### Command-line Interface
3. **Server Management Script** (`rserver.ps1`): A unified script for managing the R server (starting, stopping, executing commands)

### Convenience Wrappers
4. **Command Wrapper** (`r_command.ps1`): A simple wrapper for executing R commands
5. **Server Starter** (`start_server.bat`): A batch file for easily starting the R server

### Utility
6. **Package Check** (`check_packages.R`): A script to verify and install required R packages

This layered approach allows users of different skill levels to interact with the system at their preferred level of abstraction.

## Tool Details

### 1. R JSON HTTP Server (`r_json_server.R`)

This script creates a persistent HTTP server in R that listens for commands, executes them, and returns the results in JSON format.

**Key Features:**
- Maintains state between commands (variables, data, models)
- Captures console output and errors
- Handles plot creation and automatically saves plots as PNG files
- Provides special handling for complex R objects (models, data frames, etc.)
- Provides server status and state querying

**Usage:**
```bash
# Start interactively
Rscript r_json_server.R

# Start with custom port
Rscript r_json_server.R --port 8081

# Start in background mode
Rscript r_json_server.R --background

# Execute a single command
Rscript r_json_server.R --command "summary(mtcars)"
```

### 2. PowerShell Client (`r_json_client.ps1`)

This script provides PowerShell functions for communicating with the R server. It serves as the API layer between PowerShell and the R server.

**Key Functions:**
- `Test-RServer`: Check if the R server is running
- `Get-RServerStatus`: Get server status information
- `Get-RServerState`: Get detailed server state (variables, uptime, etc.)
- `Invoke-RCommand`: Execute an R command on the server
- `Start-RServer`: Start the R server
- `Stop-RServer`: Shutdown the R server

**Usage:**
```powershell
# Import the module
. .\r_json_client.ps1

# Execute a command
Invoke-RCommand -Command "summary(mtcars)"

# Get server state
Get-RServerState

# Start the server with a specific working directory
Start-RServer -WorkingDirectory "C:\Projects\MyAnalysis"
```

### 3. Server Management Script (`rserver.ps1`)

This script provides a unified command-line interface for managing the R server and executing commands. It builds upon the functions in `r_json_client.ps1` to provide a user-friendly interface.

**Key Actions:**
- `start`: Start the R server
- `status`: Check server status
- `execute` (or `e`): Execute an R command
- `shutdown`: Shutdown the server
- `help`: Display help information

**Usage:**
```powershell
# Start the server
.\rserver.ps1 start

# Start with custom options
.\rserver.ps1 start -p 8081 -b -w "C:\Projects\MyAnalysis"

# Execute a command
.\rserver.ps1 e -c "summary(mtcars)"

# Check status
.\rserver.ps1 status

# Shutdown the server
.\rserver.ps1 shutdown
```

### 4. Command Wrapper (`r_command.ps1`)

A simple wrapper script for executing R commands without needing to specify the action and command parameters. This is a convenience layer that calls `rserver.ps1` with the execute action.

**Usage:**
```powershell
# Execute a command
.\r_command.ps1 "summary(mtcars)"

# Multiple commands can be combined with semicolons
.\r_command.ps1 "x <- 5; y <- 10; x + y"
```

### 5. Server Starter (`start_server.bat`)

A batch file for easily starting the R server, especially useful for users less familiar with PowerShell. This is a convenience layer that calls `rserver.ps1` with the start action.

**Usage:**
```
# Double-click the file or run from command prompt
start_server.bat
```

### 6. Package Check (`check_packages.R`)

A script to verify and install required R packages for the LLM-driven interactive development.

**Usage:**
```r
# Source the script in R
source("check_packages.R")
```

## Intentional Redundancy and Design Considerations

The system includes some intentional redundancy to improve usability:

1. **Multiple Entry Points**: 
   - `r_command.ps1` and `rserver.ps1 execute` serve similar purposes but offer different levels of verbosity
   - `start_server.bat` and `rserver.ps1 start` provide different ways to start the server

2. **Design Benefits**:
   - The layered approach accommodates users with different PowerShell/batch experience levels
   - The separation of concerns (server, client, command-line interface) follows good software design principles
   - The redundancy in command wrappers improves usability for different user preferences

## Integration with LLM-Driven Development Workflow

These tools enable the LLM-driven interactive development workflow by:

1. Maintaining state between commands, allowing incremental development
2. Capturing output and errors for debugging and documentation
3. Saving plots and results automatically
4. Providing a simple command-line interface for LLMs to interact with R
5. Enabling project-specific working directories

## Example Workflow

```powershell
# Start the R server with a specific working directory
.\rserver.ps1 start -w "C:\Projects\MyAnalysis"

# Initialize logging in R
.\r_command.ps1 'sink("logs/session_log.txt", split=TRUE); cat("=== Session started:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "===\n")'

# Load data and explore
.\r_command.ps1 'data <- read.csv("data/mydata.csv")'
.\r_command.ps1 'summary(data)'

# Create a plot (automatically saved to r_comm/images/)
.\r_command.ps1 'plot(data$x, data$y, main="X vs Y")'

# Fit a model
.\r_command.ps1 'model <- lm(y ~ x, data=data)'
.\r_command.ps1 'summary(model)'

# Save captured console output
.\r_command.ps1 'sink()'

# Shutdown the server when done
.\rserver.ps1 shutdown
```

## Requirements

- R (>= 3.5.0)
- R packages: httpuv, jsonlite (plus rmarkdown, knitr for documentation)
- PowerShell 5.1 or higher

## Security Note

These tools are designed for local use only. The R server listens only on localhost (127.0.0.1) and has no authentication. Do not expose the server to external networks. 