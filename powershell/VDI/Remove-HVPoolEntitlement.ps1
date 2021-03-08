param([string]$ConnectionServer,[string]$domain)

if ($null -ne $ConnectionServer) {
    Import-Module vmware.hv.helper
    if (!$global:defaultHVServers) { Connect-HVServer -Server $ConnectionServer -Credential (Get-Credential) }

    $studentpools = @(
        "foo"
        "bar"
    )

    $pools = Get-HVPool | Where-Object {$studentpools -contains $_.base.name }

    foreach ($pool in $pools) {
        Write-Host "Removing `"Domain Users`" from $($pool.base.name)" -ForegroundColor Cyan
        Remove-HVEntitlement -User "$domain\Domain Users" -Type Group -ResourceName "$($pool.base.name)" -Confirm:$false
    }
}
