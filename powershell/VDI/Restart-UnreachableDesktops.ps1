param(
    [string]$ConnectionServer="CS",
    [string]$vCenter="VCSA"
)

if (($null -ne $ConnectionServer) -and ($null -ne $vCenter)) {
    Import-Module vmware.hv.helper
    Connect-HVServer -Server $ConnectionServer
    
    $machines = Get-HVMachine -State AGENT_UNREACHABLE

    Connect-VIServer -Server $vCenter

    foreach ($vm in $machines) {
        Get-VM -Name $($vm.base.name) | Restart-VM
    }
} else {
    Write-Host "`$ConnectionServer or `$vCenter not specified. Please re-run script with valid parameters."
}
