param($server)

Import-Module vmware.hv.helper
if (!$global:defaulthvservers) { Connect-HVServer -Server $server -Credential (Get-Credential) }
$pools = Get-HVPool
$fix = @(
    "foo"
    "bar"
)
foreach ($pool in $pools) {
    if ($fix -contains $pool.base.name) {
        Write-Host "setting logoff timeout for $($pool.base.name)" -ForegroundColor Green
        Set-HVPool -Pool $pool -Key "desktopSettings.logoffSettings.automaticLogoffPolicy" -Value "AFTER"
        Set-HVpool -Pool $pool -Key "desktopSettings.logoffSettings.automaticLogoffMinutes" -Value 30
        Set-HVpool -Pool $pool -Key "desktopSettings.logoffSettings.deleteOrRefreshMachineAfterLogoff" -Value "REFRESH"
    }    
}
