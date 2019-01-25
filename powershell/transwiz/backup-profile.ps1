param(
    [string]$backupfolder="\\server\share\folder",
    [string]$computername=$env:computername,
    [string]$domain="DOMAIN",
    [string]$username
)

if ($username -eq $null) { exit 1 }

$date = Get-Date -Format "yyyyMMdd-hh-mm-ss-tt"

if (!(Test-Path "$backupfolder\$computername")) {
    New-Item -ItemType Directory -Path "$backupfolder\$computername"
}

Write-Output "Backing up $username..."
\\server\share\folder\Transwiz.exe /BACKUP /SOURCEACCOUNT "$domain\$username" /TRANSFERFILE "$backupfolder\$computername\$username.trans.zip" /LOG "$backupfolder\$computername\transwiz-backup-one-$computername-$username-$date.log"
