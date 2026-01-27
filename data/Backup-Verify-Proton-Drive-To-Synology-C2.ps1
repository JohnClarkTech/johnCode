# Define the folder to check
$SourceFolder = "C:\Users\YourName\ProtonDrive\Taxes2025"
$ReportFile = "$SourceFolder\IntegrityManifest.txt"

# Generate SHA256 hashes for all files in the folder
Write-Host "Generating Integrity Manifest..." -ForegroundColor Cyan
Get-ChildItem -Path $SourceFolder -Recurse -File | 
    Get-FileHash -Algorithm SHA256 | 
    Select-Object Hash, Path | 
    Out-File -FilePath $ReportFile

Write-Host "Manifest created at $ReportFile" -ForegroundColor Green