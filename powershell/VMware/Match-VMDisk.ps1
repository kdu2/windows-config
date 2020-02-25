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
        foreach ($VirtualDiskDevice  in ($VMView.Config.Hardware.Device | Where {$_.ControllerKey -eq $VirtualSCSIController.Key})) {
            $VMSummary = "" | Select-Object VM, HostName, PowerState, DiskFile, DiskName, DiskSize, SCSIController, SCSITarget
            $VMSummary.VM = $VM.Name
            $VMSummary.HostName = $VMView.Guest.HostName
            $VMSummary.PowerState = $VM.PowerState
            $VMSummary.DiskFile = $VirtualDiskDevice.Backing.FileName
            $VMSummary.DiskName = $VirtualDiskDevice.DeviceInfo.Label
            $VMSummary.DiskSize = $VirtualDiskDevice.CapacityInKB * 1KB
            $VMSummary.SCSIController = $VirtualSCSIController.BusNumber
            $VMSummary.SCSITarget = $VirtualDiskDevice.UnitNumber
            $VMSummaries += $VMSummary
        }
    }

$Disks = Get-WmiObject -Class Win32_DiskDrive -ComputerName $servername
$Diff = $Disks.SCSIPort | Sort-Object -Descending | Select-Object -last 1 
foreach ($device in $VMSummaries) {
    $Disks | foreach {
                if ((($_.SCSIPort - $Diff) -eq $device.SCSIController) -and ($_.SCSITargetID -eq $device.SCSITarget)) {
                    $DiskMatch = "" | Select-Object VMWareDisk, VMWareDiskSize, WindowsDeviceID, WindowsDiskSize 
                    $DiskMatch.VMWareDisk = $device.DiskName
                    $DiskMatch.WindowsDeviceID = $_.DeviceID.Substring(4)
                    $DiskMatch.VMWareDiskSize = $device.DiskSize/1gb
                    $DiskMatch.WindowsDiskSize =  [decimal]::round($_.Size/1gb)
                    $DiskMatches += $DiskMatch
                }
            }
}

$DiskMatches | Export-Csv -NoTypeInformation -Path "c:\temp\$($VM.Name)drive_matches.csv"
