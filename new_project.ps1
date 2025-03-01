param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectPath
)

# Ensure path exists
if (-not (Test-Path -Path $ProjectPath)) {
    Write-Error "The specified path does not exist: $ProjectPath"
    exit 1
}

$FullPath = Join-Path -Path $ProjectPath -ChildPath $ProjectName

# Ensure project directory doesn't already exist
if (Test-Path -Path $FullPath) {
    Write-Error "A directory with this name already exists at: $FullPath"
    exit 1
}

# Create project from template
Write-Host "Creating new project: $ProjectName at $FullPath"
Copy-Item -Path "templates/basic_project" -Destination $FullPath -Recurse

# Determine platform and copy appropriate tools
if (Test-Path -Path "tools") {
    Write-Host "Copying R integration tools..."
    if (-not (Test-Path -Path "$FullPath/r_tools")) {
        New-Item -Path "$FullPath/r_tools" -ItemType Directory | Out-Null
    }
    
    # Always copy core R tools that are platform-neutral
    if (Test-Path -Path "tools/core") {
        Write-Host "Copying core R tools..."
        Copy-Item -Path "tools/core/*" -Destination "$FullPath/r_tools/" -Recurse
    }
    
    # Detect operating system and copy platform-specific tools
    if ($IsWindows -or $env:OS -match "Windows") {
        Write-Host "Detected Windows platform, copying Windows-specific tools..."
        if (Test-Path -Path "tools/windows") {
            Copy-Item -Path "tools/windows/*" -Destination "$FullPath/r_tools/" -Recurse
        }
    } elseif ($IsLinux -or $IsMacOS) {
        Write-Host "Detected Unix platform, copying Unix-specific tools..."
        if (Test-Path -Path "tools/unix") {
            Copy-Item -Path "tools/unix/*" -Destination "$FullPath/r_tools/" -Recurse
            # Make shell scripts executable
            if ($IsLinux -or $IsMacOS) {
                Get-ChildItem -Path "$FullPath/r_tools/*.sh" | ForEach-Object {
                    chmod +x $_.FullName
                }
            }
        }
    } else {
        # Fallback for older PowerShell versions that don't have $IsWindows
        Write-Host "Platform detection inconclusive, copying both Windows and Unix tools..."
        if (Test-Path -Path "tools/windows") {
            Copy-Item -Path "tools/windows/*" -Destination "$FullPath/r_tools/" -Recurse
        }
        if (Test-Path -Path "tools/unix") {
            Copy-Item -Path "tools/unix/*" -Destination "$FullPath/r_tools/" -Recurse
        }
    }
} else {
    Write-Warning "Tools directory not found. Please manually copy the R integration tools."
}

# Update meta_log.md with current date
$MetaLogPath = "$FullPath/llm_artifacts/meta_log.md"
$CurrentDate = Get-Date -Format "yyyy-MM-dd"
if (Test-Path -Path $MetaLogPath) {
    Write-Host "Updating meta log with current date..."
    (Get-Content $MetaLogPath) -replace "YYYY-MM-DD", $CurrentDate | Set-Content $MetaLogPath
    (Get-Content $MetaLogPath) -replace "Project Name", $ProjectName | Set-Content $MetaLogPath
}

# Update README.md with project name
$ReadmePath = "$FullPath/README.md"
if (Test-Path -Path $ReadmePath) {
    Write-Host "Updating README with project name..."
    (Get-Content $ReadmePath) -replace "Project Name", $ProjectName | Set-Content $ReadmePath
}

Write-Host "`nProject created successfully!`n" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update the project README.md with your project description"
Write-Host "2. Review and customize the meta_log.md file"
Write-Host "3. Start the R server with:"

# Provide platform-specific instructions
if ($IsWindows -or $env:OS -match "Windows") {
    Write-Host "   cd $FullPath"
    Write-Host "   .\r_tools\rserver.ps1 start"
    Write-Host "   # Execute R commands with: .\r_tools\r_command.ps1 ""your_r_code"""
} elseif ($IsLinux -or $IsMacOS) {
    Write-Host "   cd $FullPath"
    Write-Host "   ./r_tools/rserver.sh start"
    Write-Host "   # Execute R commands with: ./r_tools/r_command.sh ""your_r_code"""
} else {
    Write-Host "   cd $FullPath"
    Write-Host "   .\r_tools\rserver.ps1 start    # For Windows"
    Write-Host "   ./r_tools/rserver.sh start     # For Unix/Linux/macOS"
}

Write-Host "`nHappy analysing!" 