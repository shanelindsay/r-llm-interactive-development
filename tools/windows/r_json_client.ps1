# R JSON Client
# PowerShell functions for communicating with the R JSON server

# Default settings
$script:ServerPort = 8080
$script:ServerHostName = "127.0.0.1"
$script:DefaultTimeout = 30 # seconds
$script:ImagesDir = "r_comm/images"
$script:ProcessPidFile = "r_comm/r_process_pid.txt"
$script:ProcessStateFile = "r_comm/r_process_state.txt"
$script:HeartbeatFile = "r_comm/heartbeat.txt"

# Create r_comm directory if it doesn't exist
if (-not (Test-Path "r_comm")) {
    New-Item -ItemType Directory -Path "r_comm" | Out-Null
}

# Create images directory if it doesn't exist
if (-not (Test-Path $script:ImagesDir)) {
    New-Item -ItemType Directory -Path $script:ImagesDir | Out-Null
}

# Helper function to check if the server is running
function Test-RServer {
    [CmdletBinding()]
    param (
        [int]$Port = $script:ServerPort,
        [string]$HostName = $script:ServerHostName,
        [int]$Timeout = 5
    )

    try {
        $request = [System.Net.WebRequest]::Create("http://$HostName`:$Port/status")
        $request.Method = "GET"
        $request.Timeout = $Timeout * 1000

        try {
            $response = $request.GetResponse()
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()

            $responseObj = $content | ConvertFrom-Json
            return $true
        }
        catch {
            return $false
        }
    }
    catch {
        return $false
    }
}

# Function to get server status
function Get-RServerStatus {
    [CmdletBinding()]
    param (
        [int]$Port = $script:ServerPort,
        [string]$HostName = $script:ServerHostName,
        [int]$Timeout = $script:DefaultTimeout
    )

    try {
        $request = [System.Net.WebRequest]::Create("http://$HostName`:$Port/status")
        $request.Method = "GET"
        $request.Timeout = $Timeout * 1000

        try {
            $response = $request.GetResponse()
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()

            $responseObj = $content | ConvertFrom-Json
            return $responseObj
        }
        catch {
            Write-Error "Error connecting to R server: $_"
            return $null
        }
    }
    catch {
        Write-Error "Error creating request: $_"
        return $null
    }
}

# Function to get detailed server state
function Get-RServerState {
    [CmdletBinding()]
    param (
        [int]$Port = $script:ServerPort,
        [string]$HostName = $script:ServerHostName,
        [int]$Timeout = $script:DefaultTimeout
    )

    try {
        $request = [System.Net.WebRequest]::Create("http://$HostName`:$Port/state")
        $request.Method = "GET"
        $request.Timeout = $Timeout * 1000

        try {
            $response = $request.GetResponse()
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()

            $responseObj = $content | ConvertFrom-Json
            return $responseObj
        }
        catch {
            Write-Error "Error connecting to R server: $_"
            return $null
        }
    }
    catch {
        Write-Error "Error creating request: $_"
        return $null
    }
}

# Function to execute an R command
function Invoke-RCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Command,
        [int]$Port = $script:ServerPort,
        [string]$HostName = $script:ServerHostName,
        [int]$Timeout = $script:DefaultTimeout,
        [switch]$Raw
    )

    # Check if server is running
    if (-not (Test-RServer -Port $Port -HostName $HostName)) {
        Write-Error "R server is not running. Please start the server first."
        return $null
    }

    try {
        $request = [System.Net.WebRequest]::Create("http://$HostName`:$Port/execute")
        $request.Method = "POST"
        $request.ContentType = "application/json"
        $request.Timeout = $Timeout * 1000

        # Prepare request data
        $requestData = @{
            command = $Command
        } | ConvertTo-Json

        $requestBytes = [System.Text.Encoding]::UTF8.GetBytes($requestData)
        $request.ContentLength = $requestBytes.Length

        # Send request
        try {
            $requestStream = $request.GetRequestStream()
            $requestStream.Write($requestBytes, 0, $requestBytes.Length)
            $requestStream.Close()

            $response = $request.GetResponse()
            $responseStream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($responseStream)
            $responseContent = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()

            $responseObj = $responseContent | ConvertFrom-Json

            # If raw output is requested, return the full response object
            if ($Raw) {
                return $responseObj
            }

            # Display output
            if ($responseObj.output -and $responseObj.output.Trim() -ne "") {
                Write-Host $responseObj.output
            }

            # Display warnings
            if ($responseObj.warning -and $responseObj.warning.Count -gt 0) {
                Write-Warning ($responseObj.warning -join "`n")
            }

            # Display errors
            if ($responseObj.error -and $responseObj.error.Trim() -ne "") {
                Write-Error $responseObj.error
            }

            # Display plot information
            if ($responseObj.plots -and $responseObj.plots.Count -gt 0) {
                Write-Host "`nPlots saved to:" -ForegroundColor Cyan
                foreach ($plot in $responseObj.plots) {
                    Write-Host "  $plot"
                }
            }

            # Return result summary if available
            if ($responseObj.result_summary) {
                return $responseObj.result_summary
            }
            
            return $responseObj
        }
        catch {
            Write-Error "Error executing R command: $_"
            return $null
        }
    }
    catch {
        Write-Error "Error creating request: $_"
        return $null
    }
}

# Function to start the R server
function Start-RServer {
    [CmdletBinding()]
    param (
        [int]$Port = $script:ServerPort,
        [string]$WorkingDirectory = $PWD.Path,
        [switch]$Background,
        [switch]$Wait
    )

    # Check if server is already running
    if (Test-RServer -Port $Port) {
        Write-Warning "R server is already running on port $Port"
        return
    }

    # Ensure the working directory exists
    if (-not (Test-Path $WorkingDirectory)) {
        Write-Error "Working directory does not exist: $WorkingDirectory"
        return
    }

    # Set up arguments
    $rScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "r_json_server.R"
    if (-not (Test-Path $rScriptPath)) {
        Write-Error "R server script not found: $rScriptPath"
        return
    }

    $arguments = @(
        "-e", 
        "`"setwd('$($WorkingDirectory.Replace('\', '\\'))'); source('$($rScriptPath.Replace('\', '\\'))')`""
    )

    if ($Background) {
        $arguments += @("--background", "-p", "$Port")
    } else {
        $arguments += @("-p", "$Port")
    }

    # Start the R process
    try {
        $startInfo = New-Object System.Diagnostics.ProcessStartInfo
        $startInfo.FileName = "Rscript"
        $startInfo.Arguments = $arguments -join " "
        $startInfo.WorkingDirectory = $WorkingDirectory
        $startInfo.RedirectStandardOutput = $false
        $startInfo.RedirectStandardError = $false
        $startInfo.UseShellExecute = $true
        $startInfo.CreateNoWindow = $false

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $startInfo
        $process.Start() | Out-Null

        Write-Host "Starting R server on port $Port..."
        
        # Wait for the server to start
        $maxWaitTime = 30 # seconds
        $waitInterval = 0.5 # seconds
        $elapsed = 0

        while ($elapsed -lt $maxWaitTime) {
            if (Test-RServer -Port $Port) {
                $status = Get-RServerStatus -Port $Port
                Write-Host "R server started successfully. PID: $($status.pid), R version: $($status.r_version)"
                break
            }
            Start-Sleep -Seconds $waitInterval
            $elapsed += $waitInterval
        }

        if ($elapsed -ge $maxWaitTime) {
            Write-Warning "Timed out waiting for R server to start"
        }

        # If wait flag is specified, wait for the process to exit
        if ($Wait -and -not $Background) {
            $process.WaitForExit()
        }
    }
    catch {
        Write-Error "Error starting R server: $_"
    }
}

# Function to stop the R server
function Stop-RServer {
    [CmdletBinding()]
    param (
        [int]$Port = $script:ServerPort,
        [string]$HostName = $script:ServerHostName
    )

    # Check if server is running
    if (-not (Test-RServer -Port $Port -HostName $HostName)) {
        Write-Warning "R server is not running on port $Port"
        return
    }

    try {
        $request = [System.Net.WebRequest]::Create("http://$HostName`:$Port/shutdown")
        $request.Method = "GET"
        $request.Timeout = 5000

        try {
            $response = $request.GetResponse()
            $stream = $response.GetResponseStream()
            $reader = New-Object System.IO.StreamReader($stream)
            $content = $reader.ReadToEnd()
            $reader.Close()
            $response.Close()

            Write-Host "R server shutdown requested. Waiting for server to stop..."
            
            # Wait for the server to stop
            $maxWaitTime = 10 # seconds
            $waitInterval = 0.5 # seconds
            $elapsed = 0

            while ($elapsed -lt $maxWaitTime) {
                if (-not (Test-RServer -Port $Port -HostName $HostName -Timeout 1)) {
                    Write-Host "R server stopped successfully."
                    break
                }
                Start-Sleep -Seconds $waitInterval
                $elapsed += $waitInterval
            }

            if ($elapsed -ge $maxWaitTime) {
                Write-Warning "Timed out waiting for R server to stop"
            }
        }
        catch {
            Write-Error "Error sending shutdown request: $_"
        }
    }
    catch {
        Write-Error "Error creating request: $_"
    }
}

# Export functions
Export-ModuleMember -Function Test-RServer, Get-RServerStatus, Get-RServerState, Invoke-RCommand, Start-RServer, Stop-RServer 