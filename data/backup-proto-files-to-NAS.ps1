# 1. Load Environment Variables from the 'data' subfolder
$EnvFile = Join-Path $PSScriptRoot ".env"

if (Test-Path $EnvFile) {
    Get-Content $EnvFile | Where-Object { $_ -match "=" -and $_ -notmatch "^#" } | ForEach-Object {
        $name, $value = $_.Split('=', 2)
        
        # CLEANUP: Trim spaces AND remove any literal " or ' characters
        $cleanValue = $value.Trim().Trim('"').Trim("'")
        
        [Environment]::SetEnvironmentVariable($name.Trim(), $cleanValue, "Process")
    }
} else {
    Write-Error "CRITICAL: .env file not found at $EnvFile"
    exit
}
# 2. Define the Tasks (Pulling directly from the environment)
$Tasks = @(
    @{ Name = "Photos"; Source = $env:PHOTO_SOURCE; Dest = $env:PHOTO_NAS; Threads = 32 },
    @{ Name = "Docs";   Source = $env:DOC_SOURCE;   Dest = $env:DOC_NAS;   Threads = 8 }
)

# 3. Execute with Graceful Skipping
foreach ($Task in $Tasks) {
    # Check if BOTH source and destination variables exist for this task
    if (-not $Task.Source -or -not $Task.Dest) {
        Write-Host "Skipping $($Task.Name): Paths not defined in .env (or commented out)." -ForegroundColor Yellow
        continue
    }

    Write-Host "Starting Sync for: $($Task.Name)" -ForegroundColor Cyan
    
    # Ensure the Source actually exists on disk
    if (Test-Path $Task.Source) {
        # Ensure the Log Directory exists before Robocopy tries to write to it
        if (-not (Test-Path $env:LOG_DIR)) { New-Item -Path $env:LOG_DIR -ItemType Directory -Force }

        $LogPath = Join-Path $env:LOG_DIR "SyncLog.txt"
        
        # Run Robocopy
        robocopy $Task.Source $Task.Dest /MIR /MT:$($Task.Threads) /R:3 /W:5 /NP /LOG+:"$LogPath"
    } else {
        Write-Warning "Source path not found for $($Task.Name): $($Task.Source)"
    }
}