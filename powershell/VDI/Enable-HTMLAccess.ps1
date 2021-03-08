param(
    $connectionserver
)

Import-Module vmware.hv.helper
Connect-HVServer -Server $connectionserver -Credential (Get-Credential)
$pools = Get-HVPool
foreach ($pool in $pools) {
    if (!$pool.desktopSettings.displayProtocolSettings.enableHTMLAccess) {
        Set-HVPool -Pool $pool -Key "desktopSettings.displayProtocolSettings.enableHTMLAccess" -Value $true
    }    
}
