param(
    [string]$backupfolder="\\server\share\folder",
    [string]$computername=$env:computername
)

$date = Get-Date -Format "yyyyMMdd-hh-mm-ss-tt"

$backups = Get-ChildItem -Path "$backupfolder\$computername" -File -Filter "*.trans.zip"

foreach ($backup in $backups) {
    Write-Output "Restoring $($backup.trimend(".trans.zip"))..."
    \\server\share\folder\Transwiz.exe /RESTORE /TRANSFERFILE "$backupfolder\$computername\$($backup.name)" /LOG "$backupfolder\$computername\transwiz-restore-all-$computername-$($backup.trimend(".trans.zip"))-$date.log" | Out-Null
}
