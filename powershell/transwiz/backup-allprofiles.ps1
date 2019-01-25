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
    if (Test-Path -Path $userprofile.localpath) {
        $UserSID = $userprofile.SID
        $user = ([ADSI]"LDAP://<SID=$UserSID>").Properties["samaccountname"]
        if (!(Test-Path -Path "$backupfolder\$computername\$user")) {
            New-Item -ItemType Directory -Path "$backupfolder\$computername\$user"
        }
        Write-Output "Backing up $user..."
        \\server\share\folder\Transwiz.exe /BACKUP /SOURCEACCOUNT "$domain\$user" /TRANSFERFILE "$backupfolder\$computername\$user\$user.trans.zip" /LOG "$backupfolder\$computername\$user\transwiz-backup-all-$computername-$user-$date.log" | Out-Null
    }
}
