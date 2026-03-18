# --- CONFIGURATION ---
$serverIP   = "10.10.10.9"
$shareName  = "backups"

$smbPath    = "\\$serverIP\$shareName"
$sourceDir  = "$env:LOCALAPPDATA\Hinterland\TheLongDark"
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupDir  = Join-Path $smbPath "TLD_Backups\$timestamp"

# --- EXECUTION ---
if (Test-Path $smbPath) {
    Write-Host "Connected to $serverIP. Performing Deep Scan for survival files..." -ForegroundColor Green
    
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

    # Deep scan: Look in all sub-directories (-Recurse) for specific names
    $includeList = @("sandbox5", "profile_survival*", "user.001", "user001")
    $foundFiles = Get-ChildItem -Path $sourceDir -Include $includeList -File -Recurse -ErrorAction SilentlyContinue

    if ($foundFiles.Count -eq 0) {
        Write-Warning "Deep Scan failed. Let's list what IS in that folder:"
        Get-ChildItem -Path $sourceDir -Recurse | Select-Object FullName | Out-Host
    } else {
        foreach ($file in $foundFiles) {
            # Use the literal FullName to copy
            Copy-Item -Path $file.FullName -Destination $backupDir -Force
            $sizeMB = [math]::Round($file.Length / 1MB, 2)
            Write-Host " [✓] Found & Copied: $($file.Name) ($sizeMB MB)" -ForegroundColor Gray
        }

        $totalMB = [math]::Round((Get-ChildItem $backupDir | Measure-Object -Property Length -Sum).Sum / 1MB, 2)
        Write-Host "---"
        Write-Host "Survival Backup Successful to: $backupDir" -ForegroundColor Cyan
        Write-Host "Total Backup Size: $totalMB MB" -ForegroundColor White
    }
}
else {
    Write-Warning "Target SMB share unreachable: $smbPath"
}