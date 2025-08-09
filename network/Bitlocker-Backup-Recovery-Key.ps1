if ($recoveryKeyProtector) {
    Backup-BitLockerKeyProtector -MountPoint "C:" -KeyProtectorId $recoveryKeyProtector.KeyProtectorId -Path "C:\BitLocker_Recovery_Keys"
} else {
    Write-Host "No recovery password protector found. You may need to add one first."
}