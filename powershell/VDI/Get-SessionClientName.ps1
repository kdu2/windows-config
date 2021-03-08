param(
    [Parameter(Mandatory=$true)]
    [string]$username,
    [string]$server
)

Import-Module vmware.hv.helper
Connect-HVServer -Server $server

$sessions = Get-HVLocalSession | Where-Object { $_.NamesData.UserName -like "*$($username)*" }

Write-Host ""
foreach ($session in $sessions) {
    Write-Host "$($session.NamesData.UserName) $($session.NamesData.ClientName)"
}
