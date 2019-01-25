param(
    [string]$backupfolder="\\server\share\folder",
    [string]$computername=$env:computername
)

$date = Get-Date -Format "yyyyMMdd-hh-mm-ss-tt"

$backups = Get-ChildItem -Path "$backupfolder\$computername" -File -Filter "*.trans.zip" -Recurse

foreach ($backup in $backups) {
    Write-Output "Restoring $($backup.name.trimend(".trans.zip"))..."
    \\server\share\folder\Transwiz.exe /RESTORE /TRANSFERFILE "$($backup.fullname)" /LOG "$backupfolder\$computername\$($backup.name.trimend(".trans.zip"))\transwiz-restore-all-$computername-$($backup.name.trimend(".trans.zip"))-$date.log" | Out-Null
}
