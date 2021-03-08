function Detach-Disk {
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
        [string]$CanonicalName
    )

    $storSys = Get-View $VMHost.Extensiondata.ConfigManager.StorageSystem
    $lunUuid = (Get-ScsiLun -VmHost $VMHost | Where-Object {$_.CanonicalName -eq $CanonicalName}).ExtensionData.Uuid

    $storSys.DetachScsiLun($lunUuid)
}

function Detach-Lun {
    param(
        $LunIDs,
        $servermodel
    )    

    $VMHosts = Get-VMHost * | Where-Object { $_.Model -eq $servermodel }

    foreach ($VMHost in $VMHosts) {
        foreach ($LUNid in $LunIDs) {
            Write-Host "Detaching" $LUNid "from" $VMHost -ForegroundColor "Yellow"
            Detach-Disk -VMHost $VMHost -CanonicalName $LUNid
        }
    }
}
