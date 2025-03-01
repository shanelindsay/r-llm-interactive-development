# R Server Management Script
# This script provides a unified interface for managing the R JSON server

param (
    [Parameter(Position = 0)]
    [ValidateSet("start", "status", "execute", "e", "shutdown", "help")]
    [string]$Action = "help",
    
    [Parameter()]
    [Alias("p")]
    [int]$Port = 8080,
    
    [Parameter()]
    [Alias("h")]
    [string]$HostName = "127.0.0.1",
    
    [Parameter()]
    [Alias("w")]
    [string]$WorkingDirectory = $PWD.Path,
    
    [Parameter()]
    [Alias("b")]
    [switch]$Background,
    
    [Parameter()]
    [Alias("c")]
    [string]$Command,
    
    [Parameter()]
    [switch]$Wait
)

# Make sure we're working with the right encoding
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Import the client functions
$clientPath = Join-Path -Path $PSScriptRoot -ChildPath "r_json_client.ps1"
if (Test-Path $clientPath) {
    . $clientPath
}
else {
    Write-Error "Required script not found: $clientPath"
    exit 1
}

# Execute the specified action
switch ($Action) {
    "start" {
        Write-Host "Starting R server..." -ForegroundColor Cyan
        
        # Clean up any existing state files
        $processStateFile = "r_comm/r_process_state.txt"
        $heartbeatFile = "r_comm/heartbeat.txt"
        $processPidFile = "r_comm/r_process_pid.txt"
        
        if ((Test-Path $processStateFile) -or (Test-Path $heartbeatFile) -or (Test-Path $processPidFile)) {
            Write-Host "Cleaning up state files from previous runs..." -ForegroundColor Yellow
            if (Test-Path $processStateFile) { Remove-Item $processStateFile }
            if (Test-Path $heartbeatFile) { Remove-Item $heartbeatFile }
            if (Test-Path $processPidFile) { Remove-Item $processPidFile }
        }
        
        # Start the server
        Start-RServer -Port $Port -WorkingDirectory $WorkingDirectory -Background:$Background -Wait:$Wait
    }
    
    "status" {
        if (Test-RServer -Port $Port -HostName $HostName) {
            $status = Get-RServerStatus -Port $Port -HostName $HostName
            Write-Host "R server is running" -ForegroundColor Green
            Write-Host "  Port: $Port"
            Write-Host "  PID: $($status.pid)"
            Write-Host "  R Version: $($status.r_version)"
            Write-Host "  Uptime: $($status.uptime) seconds"
            
            # Get more detailed state
            $state = Get-RServerState -Port $Port -HostName $HostName
            Write-Host "`nServer State:" -ForegroundColor Cyan
            Write-Host "  Last Call Time: $($state.last_call_time)"
            Write-Host "  Command Count: $($state.command_count)"
            Write-Host "  Variables: $($state.variables.Count) objects in environment"
            
            # List variables if there are any
            if ($state.variables.Count -gt 0) {
                Write-Host "`nVariables in R environment:" -ForegroundColor Cyan
                foreach ($var in $state.variables) {
                    Write-Host "  $var"
                }
            }
        }
        else {
            Write-Host "R server is not running" -ForegroundColor Red
        }
    }
    
    { $_ -eq "execute" -or $_ -eq "e" } {
        if (-not $Command) {
            Write-Error "Command parameter (-c) is required for 'execute' action"
            exit 1
        }
        
        if (Test-RServer -Port $Port -HostName $HostName) {
            Write-Host "Executing R command: $Command" -ForegroundColor Cyan
            Invoke-RCommand -Command $Command -Port $Port -HostName $HostName
        }
        else {
            Write-Error "R server is not running. Please start the server first."
            exit 1
        }
    }
    
    "shutdown" {
        if (Test-RServer -Port $Port -HostName $HostName) {
            Write-Host "Shutting down R server..." -ForegroundColor Cyan
            Stop-RServer -Port $Port -HostName $HostName
        }
        else {
            Write-Host "R server is not running" -ForegroundColor Yellow
        }
    }
    
    "help" {
        Write-Host "R Server Management Script" -ForegroundColor Cyan
        Write-Host "Usage: .\rserver.ps1 <action> [options]" -ForegroundColor White
        Write-Host "`nActions:" -ForegroundColor Yellow
        Write-Host "  start      Start the R server"
        Write-Host "  status     Check the status of the R server"
        Write-Host "  execute    Execute an R command (alias: e)"
        Write-Host "  shutdown   Shutdown the R server"
        Write-Host "  help       Display this help message"
        
        Write-Host "`nOptions:" -ForegroundColor Yellow
        Write-Host "  -Port, -p <port>                  Specify the server port (default: 8080)"
        Write-Host "  -HostName, -h <hostname>          Specify the server hostname (default: 127.0.0.1)"
        Write-Host "  -WorkingDirectory, -w <dir>       Specify working directory (for 'start' action)"
        Write-Host "  -Background, -b                   Run in background mode (for 'start' action)"
        Write-Host "  -Command, -c <command>            R command to execute (for 'execute' action)"
        Write-Host "  -Wait                             Wait for the server to exit (for 'start' action)"
        
        Write-Host "`nExamples:" -ForegroundColor Yellow
        Write-Host "  .\rserver.ps1 start -w C:\Projects\MyAnalysis"
        Write-Host "  .\rserver.ps1 start -p 8081 -b"
        Write-Host "  .\rserver.ps1 status"
        Write-Host "  .\rserver.ps1 e -c `"summary(mtcars)`""
        Write-Host "  .\rserver.ps1 execute -c `"plot(1:10)`""
        Write-Host "  .\rserver.ps1 shutdown"
    }
} 