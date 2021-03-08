function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "usercleanup.log"
}

$excluded = Get-Content "excludedusers.txt"

$profiles = Get-CimInstance -class win32_userprofile | Where-Object { ($_.localpath -like "C:\Users\*") -and ($_.loaded -eq $false) -and ($excluded -notcontains ($_.localpath | Split-Path -Leaf)) }

$names = $profiles | Select-Object localpath
$users = $names | ForEach-Object { $_.localpath | Split-Path -Leaf }
log "$(Get-Date)`nRemoving users:"
$users | ForEach-Object { log $_ }
log ""

$profiles | Remove-CimInstance
