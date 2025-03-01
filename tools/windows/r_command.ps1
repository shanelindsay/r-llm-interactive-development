# R Command Wrapper
# Simple wrapper for executing R commands

param(
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$Command,
    
    [Parameter()]
    [int]$Port = 8080,
    
    [Parameter()]
    [string]$HostName = "127.0.0.1"
)

# Import rserver.ps1 to access the execute action
$rserverPath = Join-Path -Path $PSScriptRoot -ChildPath "rserver.ps1"
if (Test-Path $rserverPath) {
    & $rserverPath execute -c $Command -p $Port -h $HostName
}
else {
    Write-Error "Required script not found: $rserverPath"
    exit 1
} 