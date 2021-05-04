Import-Module vmware.hv.helper
if (!$global:defaulthvservers) {
    $server = Read-Host -Prompt "enter server name"
    $username = Read-Host -Prompt "enter username"
    $secpwd = Read-Host -AsSecureString -Prompt "enter password"
    $domain = Read-Host -Prompt "enter domain"
    Connect-HVServer -Server $server -User $username -Password $secpwd -Domain $domain
}

$pools = Get-HVPool
$list = @(
    "POOL01"
    "POOL02"
)

[string[]]$cs = @()
$cs += 'GRP01'
$cs += 'GRP02'

foreach ($pool in $pools) {
    if ($list -contains $pool.base.name) {
        Write-Host "setting connection server restrictions for $($pool.base.name)" -ForegroundColor Green
        Set-HVPool -Pool $pool -Key "desktopSettings.connectionServerRestrictions" -Value $cs
    }
}
