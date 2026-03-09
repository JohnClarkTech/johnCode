# --- CONFIGURATION ---
$smbPath = "\\YOUR-SERVER-NAME\YourBackupFolder"  # <--- Update to your NAS/SMB path
$source = "$env:LOCALAPPDATA\Hinterland\TheLongDark"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupDir = Join-Path $smbPath "TLD_Backups\$timestamp"

# --- EXECUTION ---
if (Test-Path $smbPath) {
    Write-Host "Connected to SMB share. Backing up Survival & Profile..." -ForegroundColor Green
    
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    # Copy the active survival run and the associated profile snapshot
    Copy-Item -Path "$source\sandbox5" -Destination $backupDir -ErrorAction SilentlyContinue
    Copy-Item -Path "$source\profile_survival.170901" -Destination $backupDir -ErrorAction SilentlyContinue

    # Copy the Global Profile (Feats, Badges, Challenges)
    Copy-Item -Path "$source\user.001" -Destination $backupDir -ErrorAction SilentlyContinue

    Write-Host "Full Backup Successful to: $backupDir" -ForegroundColor Cyan
}
else {
    Write-Warning "SMB Share unreachable. Backup aborted."
}