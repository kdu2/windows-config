# based on script from https://4sysops.com/archives/map-vmware-virtual-disks-and-windows-drive-volumes-with-a-powershell-script/

param(
    [string]$vcenter,
    [string]$vmname,
    [string]$servername
)
Import-Module VMware.VimAutomation.Core

Connect-VIServer -Server $vcenter -credential (get-credential)

$VM = Get-VM $vmname
$VMSummaries = @()
$DiskMatches = @()

$VMView = $VM | Get-View
foreach ($VirtualSCSIController in ($VMView.Config.Hardware.Device | Where-Object { $_.DeviceInfo.Label -match "SCSI Controller" })) {
    foreach ($VirtualDiskDevice in ($VMView.Config.Hardware.Device | Where-Object { $_.ControllerKey -eq $VirtualSCSIController.Key })) {
        $VMSummary = New-Object -TypeName PSObject -Property @{
            "VM" = $VM.Name
            "HostName" = $VMView.Guest.HostName
            "PowerState" = $VM.PowerState
            "DiskFile" = $VirtualDiskDevice.Backing.FileName
            "DiskName" = $VirtualDiskDevice.DeviceInfo.Label
            "DiskSize" = $VirtualDiskDevice.CapacityInKB * 1KB
            "SCSIController" = $VirtualSCSIController.BusNumber
            "SCSITarget" = $VirtualDiskDevice.UnitNumber
        }
        $VMSummaries += $VMSummary
    }
}

$Disks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $servername
$Diff = $Disks.SCSIPort | Sort-Object -Descending | Select-Object -last 1 
foreach ($device in $VMSummaries) {
    foreach ($Disk in $Disks) {
        if ((($Disk.SCSIPort - $Diff) -eq $device.SCSIController) -and ($Disk.SCSITargetID -eq $device.SCSITarget)) {
            $DiskMatch = New-Object -TypeName PSObject -Property @{
                "VMWareDisk" = $device.DiskName
                "WindowsDeviceID" = $Disk.DeviceID.Substring(4)
                "VMWareDiskSize" = $device.DiskSize/1gb
                "WindowsDiskSize" =  [decimal]::round($Disk.Size/1gb)    
            }
            $DiskMatches += $DiskMatch
        }
    }
}

$DiskMatches | Export-Csv -NoTypeInformation -Path "c:\temp\$($VM.Name)-drive_matches.csv"
