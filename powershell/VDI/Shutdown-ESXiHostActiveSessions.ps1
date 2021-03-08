param(
    [string]$vcenter,
    [string]$vmhost,
    [string]$connectionserver
)

Import-Module vmware.vimautomation.core
Import-Module vmware.hv.helper

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

$guestvms = Get-VM | Where-Object { $_.vmhost.name -eq $vmhost } | Sort-Object name | Select-Object name

Connect-HVServer -Server $connectionserver -Credential (Get-Credential)

foreach ($vm in $guestvms) {
    $current_vm = Get-HVMachine -MachineName $vm.name
    if ($current_vm.base.basicstate -eq 'CONNECTED') {
        Start-HVPool -Pool $current_vm.base.desktopname -Machines $current_vm.base.name -Refresh -LogoffSetting "FORCE_LOGOFF"
    } else {
        Stop-VMGuest -VM $vm
    }
}
