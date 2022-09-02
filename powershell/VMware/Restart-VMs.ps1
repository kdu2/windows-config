param(
    [Parameter(Mandatory=$true)]
    [string[]]$VMs,
    [string]$vcenter,
    [bool]$Wait
)

Import-Module vmware.vimautomation.core

if ($global:defaultviservers -notcontains $vcenter) {
    Connect-VIServer -Server $vcenter
}

foreach ($vm in $VMs) {
    Write-Host "Restarting $vm" -ForegroundColor Green
    Get-VM $vm | Restart-VM
    # wait 5 min 
    if ($Wait) { Start-Sleep -Seconds 300 }
}
