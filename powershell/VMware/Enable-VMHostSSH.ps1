param(
    [Parameter(Mandatory=$true)]
    [string]$vcenter
)

$modules = Get-Module

if ($modules -notcontains "vmware.vimautomation.core") { Import-Module vmware.vimautomation.core }

Connect-VIServer -server $vcenter -Credential (Get-Credential)

$hosts = Get-VMHost

foreach ($vmhost in $hosts) {
    $sshstatus = Get-VMHostService -VMHost $vmhost | Where-Object { $_.key  -eq "TSM-SSH" } | Select-Object vmhost,label,running
    if ($sshstatus.running -eq "stopped") {
        Start-VMHostService -HostService ($vmhost | Get-VMHostService | Where-Object { $_.key -eq "TSM-SSH" })
    }
    $sshstatus | Set-VMHostService -Policy "On"
}
