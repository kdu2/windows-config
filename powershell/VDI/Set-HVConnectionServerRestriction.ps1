Import-Module vmware.hv.helper
if (!$global:defaulthvservers) {
    $server = Read-Host -Prompt "enter server name"
    $username = Read-Host -Prompt "enter username"
    $secpwd = Read-Host -AsSecureString -Prompt "enter password"
    $domain = Read-Host -Prompt "enter domain"
    Connect-HVServer -Server $server -User $username -Password $secpwd -Domain $domain
}

$pools = Get-HVPool
$lab = @(
    "lab1"
    "lab2"
    "lab3"
)
$stf = @(
    "staff1"
    "staff2"
    "staff3"
)

[string[]]$cs1 = @()
$cs1 += 'LAB01'
$cs1 += 'LAB02'

[string[]]$cs2 = @()
$cs2 += 'STF01'
$cs2 += 'STF02'

foreach ($pool in $pools) {
    if ($lab -contains $pool.base.name) {
        Write-Host "setting connection server restrictions for $($pool.base.name)" -ForegroundColor Green
        Set-HVPool -Pool $pool -Key "desktopSettings.connectionServerRestrictions" -Value $cs1
    }
    if ($stf -contains $pool.base.name) {
        Write-Host "setting connection server restrictions for $($pool.base.name)" -ForegroundColor Green
        Set-HVPool -Pool $pool -Key "desktopSettings.connectionServerRestrictions" -Value $cs2
    }
}
