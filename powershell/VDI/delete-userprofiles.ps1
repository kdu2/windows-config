$pool = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID
$pools = Get-Content -Path "\\server\share\pools.txt"

if ($pools -contains $pool) {
    function log ([string]$entry) {
        Write-Output $entry | Out-File -Append "C:\logs\usercleanup.log"
    }
        
    if (!(Test-Path C:\logs)) { New-Item -ItemType Directory -Path C:\logs }    
    
    $excluded = Get-Content "\\server\share\excludedusers.txt"
    
    $profiles = Get-CimInstance -class win32_userprofile | Where-Object { ($_.localpath -like "C:\Users\*") -and ($_.loaded -eq $false) -and ($excluded -notcontains ($_.localpath | Split-Path -Leaf)) }
    
    $names = $profiles | Select-Object localpath
    $users = $names | ForEach-Object { $_.localpath | Split-Path -Leaf }
    log "$(Get-Date)`nRemoving users:"
    $users | ForEach-Object { log $_ }
    log ""
    
    $profiles | Remove-CimInstance
}
