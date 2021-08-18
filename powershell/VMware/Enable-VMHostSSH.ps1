param([string]$vcenter)

$modules = Get-Module

if ($modules -notcontains "vmware.vimautomation.core") { Import-Module vmware.vimautomation.core }

if (!$global:defaultviservers) { Connect-VIServer -server $vcenter -Credential (Get-Credential) }

$hosts = Get-VMHost

foreach ($vmhost in $hosts) {
    $sshservice = Get-VMHostService -VMHost $vmhost | Where-Object { $_.key  -eq "TSM-SSH" }
    if ($sshservice.running -eq "stopped") {
        $sshservice | Start-VMHostService
    }
    $sshservice | Set-VMHostService -Policy "On"
}
