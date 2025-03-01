# Cross-Platform Support for R-LLM Interactive Development

This document explains how the R-LLM integration toolkit provides cross-platform support for both Windows and Unix-like operating systems (Linux/macOS).

## Platform-Specific Implementation

The R-LLM toolkit uses a platform-specific approach that ensures compatibility across different operating systems while maintaining the same core functionality. Here's how the implementation works:

### Core Architecture

The toolkit follows a client-server architecture:

1. **R JSON Server** (platform-neutral): A persistent HTTP server written in R that executes R code and returns results as JSON.
2. **Client Scripts** (platform-specific): Scripts that send commands to the R server, with separate implementations for:
   - Windows (PowerShell/Batch)
   - Unix-like systems (Bash shell)

### Directory Structure

The tools are organized into three main directories:

- `/tools/core/` - Platform-neutral R scripts that work on any OS
- `/tools/windows/` - Windows-specific PowerShell and Batch scripts
- `/tools/unix/` - Unix-specific Bash scripts for Linux and macOS

## Equivalent Functionality

Each platform has a complete set of equivalent tools with matching functionality:

| Functionality | Windows | Unix/Linux/macOS |
|---------------|---------|-----------------|
| Client API | `r_json_client.ps1` | `r_json_client.sh` |
| Server management | `rserver.ps1` | `rserver.sh` |
| Command execution | `r_command.ps1` | `r_command.sh` |
| Quick server start | `start_server.bat` | `start_server.sh` |
| Project creation | `new_project.ps1` | `new_project.sh` |

## Platform Detection and Tool Selection

The project creation scripts (`new_project.ps1` and `new_project.sh`) detect the operating system and automatically copy the appropriate platform-specific tools to the new project's `r_tools` directory.

### Windows Detection

In PowerShell:
```powershell
if ($IsWindows -or $env:OS -match "Windows") {
    # Copy Windows-specific tools
}
```

### Unix Detection

In Bash:
```bash
# Unix-specific tools are automatically selected when using new_project.sh
```

## Usage Examples

### Windows (PowerShell)

```powershell
# Create a new project
.\new_project.ps1 -ProjectName "MyAnalysis" -ProjectPath "C:/Users/YourName/Projects"

# Start the R server
.\r_tools\rserver.ps1 start

# Execute an R command
.\r_tools\r_command.ps1 "summary(mtcars)"
```

### Unix/Linux/macOS (Bash)

```bash
# Create a new project
./new_project.sh "MyAnalysis" "/home/username/Projects"

# Start the R server
./r_tools/rserver.sh start

# Execute an R command
./r_tools/r_command.sh "summary(mtcars)"
```

## Common Server Protocol

Despite the platform-specific implementations, both Windows and Unix clients communicate with the R server using the same HTTP/JSON protocol:

1. HTTP requests to endpoints (execute, setwd, getwd, etc.)
2. JSON-formatted data exchange
3. Consistent response format across platforms

This ensures that the R code execution and results are identical, regardless of the operating system used.

## Contributions and Extensions

When adding new functionality to the toolkit, remember to:

1. Add platform-neutral R code to the `/tools/core/` directory
2. Implement Windows client code in the `/tools/windows/` directory
3. Implement Unix client code in the `/tools/unix/` directory
4. Update documentation to reflect the new functionality for both platforms

This consistent pattern ensures maintainability and future extensibility of the cross-platform toolkit. 