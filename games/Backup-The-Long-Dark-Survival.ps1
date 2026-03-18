# --- CONFIGURATION ---
$serverIP   = "10.10.10.9"
$shareName  = "backups"
$smbPath    = "\\$serverIP\$shareName"
$sourceDir  = "$env:LOCALAPPDATA\Hinterland\TheLongDark"
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupDir  = Join-Path $smbPath "TLD_Backups\$timestamp"

# --- EXECUTION ---
if (Test-Path $smbPath) {
    Write-Host "Connected to $serverIP. Backing up survival data..." -ForegroundColor Green
    
    if (!(Test-Path $backupDir)) { 
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null 
    }

    # Target specific sandbox, profiles, and global settings
    $includeList = @("sandbox5", "profile_survival*", "user.001", "user001")
    $foundFiles = Get-ChildItem -Path $sourceDir -Include $includeList -File -Recurse -ErrorAction SilentlyContinue

    foreach ($file in $foundFiles) {
        Copy-Item -Path $file.FullName -Destination $backupDir -Force
        $sizeMB = [math]::Round($file.Length / 1MB, 2)
        # Using standard ASCII characters to prevent Encoding ParserErrors
        Write-Host " [+] Found and Copied: $($file.Name) ($sizeMB MB)" -ForegroundColor Gray
    }

    $totalMB = [math]::Round((Get-ChildItem $backupDir | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
    Write-Host "---"
    Write-Host "Backup Successful: $backupDir" -ForegroundColor Cyan
    Write-Host "Total Size: $totalMB MB" -ForegroundColor White
}
else {
    Write-Warning "Target SMB share unreachable: $smbPath"
}