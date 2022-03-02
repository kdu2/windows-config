param(
    [Parameter(Mandatory=$true)]
    [string]$username,
    [string]$hvserver1,
    [string]$hvserver2,
    [string]$hvdomain
)

Import-Module vmware.hv.helper

$hvuser = Read-Host -Prompt "Username"
$hvpwd = Read-Host -AsSecureString -Prompt "Password"

$hvsessions1 = Connect-HVServer -Server $hvserver1 -User $hvuser -Password $hvpwd -Domain $hvdomain
$hvsessions2 = Connect-HVServer -Server $hvserver2 -User $hvuser -Password $hvpwd -Domain $hvdomain

$activesessions1 = Get-HVLocalSession -HvServer $hvsessions1 | Where-Object { $_.namesdata.username -match "$username" }
$activesessions2 = Get-HVLocalSession -HvServer $hvsessions2 | Where-Object { $_.namesdata.username -match "$username" }

if ($activesessions1 -ne $null) {
    foreach ($session in $activesessions1) {
        Write-Host "Active session(s) for $username in pool $($session.namesdata.desktopname) on $($session.namesdata.machineorrdsservername)"
    }
}

if ($activesessions2 -ne $null) {
    foreach ($session in $activesessions2) {
        Write-Host "Active session(s) for $username in pool $($session.namesdata.desktopname) on $($session.namesdata.machineorrdsservername)"
    }
}
