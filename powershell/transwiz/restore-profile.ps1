param(
    [string]$backupfolder="\\server\share\folder",
    [string]$computername=$env:computername,
    [string]$username
)

if ($username -eq $null) { exit 1 }

$date = Get-Date -Format "yyyyMMdd-hh-mm-ss-tt"

$backups = Get-ChildItem -Path "$backupfolder\$computername" -File -Filter "$username*.trans.zip"

foreach ($backup in $backups) {
    Write-Output "Restoring $($backup.trimend(".trans.zip"))..."
    \\server\share\folder\Transwiz.exe /RESTORE /TRANSFERFILE "$backupfolder\$computername\$($backup.name)" /LOG "$backupfolder\$computername\transwiz-restore-one-$computername-$($backup.trimend(".trans.zip"))-$date.log"
}
