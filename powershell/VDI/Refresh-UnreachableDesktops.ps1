param(
    [string]$pool,
    [string]$ConnectionServer,
    [string]$vCenter,
    [string]$vCenteradmin
)

if ($null -ne $ConnectionServer) {
    Import-Module vmware.hv.helper
    $secpwd = Read-Host -AsSecureString
    $cred = New-Object System.Management.Automation.PSCredential($vCenteradmin,$secpwd)
    Connect-HVServer -Server $ConnectionServer -Credential $cred

    $machines = Get-HVMachine -PoolName $pool -State AGENT_UNREACHABLE

    $desktops = @()

    foreach ($desktop in $machines) {
        $desktops += $desktop.base.name
    }

    Start-HVPool -Refresh -Pool $pool -Machines $desktops -LogoffSetting FORCE_LOGOFF -StopOnFirstError:$false  -Confirm:$false

} else {
    Write-Host "`$ConnectionServer or `$vCenter is not specified. Please re-run script with valid parameters."
}
