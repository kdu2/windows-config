param(
    [string]$ConnectionServer,
    [string]$pool,
    [string]$assignmentlist
)

Import-Module vmware.hv.helper

Connect-HVServer -Server $ConnectionServer -Credential (Get-Credential)

$list = Import-Csv $assignmentlist

$desktops = Get-HVMachine -PoolName $pool | Where-Object { $_.base.user -eq $null }

foreach ($desktop in $desktops) {
    $user = ($list | Where-Object { $_.desktop -eq ($desktop.base.name).trimend(".domainfqdn") }).user
    Set-HVMachine -MachineName $desktop.base.name -User "domain\$user"
}
