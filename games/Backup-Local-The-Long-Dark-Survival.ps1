# --- CONFIGURATION ---
$sourceDir      = "C:\Users\john\AppData\Local\Hinterland\TheLongDark\Survival"
$destinationBase = "C:\Users\john\AppData\Local\Hinterland\TheLongDark\Backups"
$timestamp      = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupDir      = Join-Path $destinationBase "TLD_Backup_$timestamp"
$logFile        = "C:\Users\john\AppData\Local\Hinterland\TheLongDark\Backup.log"
$n8nWebhookUrl  = "http://10.10.10.x:5678/webhook/tld-backup-status" # Update or remove if unused

# --- HELPER FUNCTIONS ---
function Write-Log {
    param([string]$message)
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
    Add-Content -Path $logFile -Value $logEntry
}

function Send-N8nNotification {
    param(
        [string]$status,
        [string]$message,
        [double]$totalSizeMB = 0
    )
    if ([string]::IsNullOrWhitespace($n8nWebhookUrl)) { return }
    
    $payload = @{
        status    = $status
        message   = $message
        totalMB   = $totalSizeMB
        host      = $env:COMPUTERNAME
        timestamp = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri $n8nWebhookUrl -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 10 -ErrorAction SilentlyContinue
    } catch {
        Write-Log "Failed to reach n8n webhook: $_"
    }
}

# --- EXECUTION ---
Write-Log "--- Starting Local Backup Run ---"

# Verify source directory exists
if (!(Test-Path $sourceDir)) {
    $errMsg = "Source directory not found at $sourceDir"
    Write-Log "ERROR: $errMsg"
    Send-N8nNotification -status "Failed" -message $errMsg
    exit 1
}

try {
    # Create target directory timestamp folder
    if (!(Test-Path $backupDir)) { 
        New-Item -ItemType Directory -Path $backupDir -Force -ErrorAction Stop | Out-Null 
    }

    # Fetch save files from the Survival folder
    $filesToCopy = Get-ChildItem -Path $sourceDir -File -Recurse -ErrorAction Stop

    if ($filesToCopy.Count -eq 0) {
        $warnMsg = "No save files found in $sourceDir to copy."
        Write-Log "WARNING: $warnMsg"
        Send-N8nNotification -status "Warning" -message $warnMsg
        exit 0
    }

    foreach ($file in $filesToCopy) {
        Copy-Item -Path $file.FullName -Destination $backupDir -Force -ErrorAction Stop
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        Write-Log "Copied: $($file.Name) ($sizeMB MB)"
    }

    $totalMB = [math]::Round((Get-ChildItem $backupDir | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    $succMsg = "Local backup successful to $backupDir"
    
    Write-Log "$succMsg (Total Size: $totalMB MB)"
    Send-N8nNotification -status "Success" -message $succMsg -totalSizeMB $totalMB
    exit 0
}
catch {
    $excMsg = "Exception occurred during local copy: $_"
    Write-Log "ERROR: $excMsg"
    Send-N8nNotification -status "Failed" -message $excMsg
    exit 1
}