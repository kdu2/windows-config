param(
    [string]$backupfolder="\\server\share\folder",
    [string]$computername=$env:computername,
    [string]$domain="DOMAIN"
)

$date = Get-Date -Format "yyyyMMdd-hh-mm-ss-tt"
$excludedprofiles = "admin","administrator"
$profiles = Get-WmiObject -class win32_userprofile | Where-Object { ($_.localpath -like "C:\Users\*") -and ( $excludedprofiles -notcontains ($_.localpath | Split-Path -Leaf )) }

if (!(Test-Path "$backupfolder\$computername")) {
    New-Item -ItemType Directory -Path "$backupfolder\$computername"
}

foreach ($userprofile in $profiles) {
    $UserSID = $userprofile.SID
    $user = ([ADSI]"LDAP://<SID=$UserSID>").Properties["samaccountname"]
    if (Test-Path -Path $userprofile.localpath) {
        Write-Output "Backing up $user..."
        \\server\share\folder\Transwiz.exe /BACKUP /SOURCEACCOUNT "$domain\$user" /TRANSFERFILE "$backupfolder\$computername\$user.trans.zip" /LOG "$backupfolder\$computername\transwiz-backup-all-$computername-$user-$date.log"
    }
}
