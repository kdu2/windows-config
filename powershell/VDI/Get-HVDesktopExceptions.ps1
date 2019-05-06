<#
.SYNOPSIS
   Get-HVDesktopExceptions is a script that will locate Horizon View Linked Clones that are not using the correct snapshot/image.
.DESCRIPTION
   Get-HVDesktopExceptions will find the snapshot IDs used by the desktops and the pool.
   It compares these values to find any desktops that do not match the pool.
.PARAMETER ConnectionServer
   The View Connection server that you want to run this script against.
#>

param([string]$ConnectionServer)

if ($null -ne $ConnectionServer)
{
    Import-Module vmware.hv.helper
    Connect-HVServer -Server $ConnectionServer
    $pools = Get-HVPool
    
    $DesktopExceptionsMaster = @()
    $exceptionsreport = @()

    foreach ($pool in $pools) {
        $poolsnapshot = $pool.AutomatedDesktopData.VirtualCenterNamesData.SnapshotPath
        $desktops = Get-HVMachine -PoolName $pool.base.name
        
        [string[]]$DesktopExceptions = ""

        foreach ($desktop in $desktops) {
            $desktopsnapshot = $desktop.ManagedMachineData.ViewComposerData.BaseImageSnapshotPath
            if ($desktopsnapshot -ne $poolsnapshot) {
                $DesktopExceptions += $desktop.base.name
                $exceptionsobj = New-Object PSObject -Property @{
                    "Pool" = $pool.base.name
                    "desktopexceptions" = $DesktopExceptions
                }
                $DesktopExceptionsMaster += $exceptionsobj
                $exceptionsreportobj = New-Object PSObject -Property @{
                    "PoolName" = $pool.base.name
                    "PoolSnapshot" = $poolsnapshot
                    "DesktopName" = $desktop.base.name
                    "DesktopSnapshot" = $desktopsnapshot
                }
                $exceptionsreport += $exceptionsreportobj
            }
        }
    }

    if ($null -eq $DesktopExceptionsMaster) {
        Write-Host "All desktops are using the correct snapshot."
    } else {
        $date = Get-Date -Format "yyyy-MM-dd hh.mm.sstt"
        $exceptionsreport | Select-Object DesktopName,PoolName,PoolSnapshot,DesktopSnapshot | Sort-Object DesktopName | Export-Csv "C:\logs\desktopexceptions-$date.csv" -NoTypeInformation
        $exceptionsreport | Select-Object DesktopName,PoolName,PoolSnapshot,DesktopSnapshot | Sort-Object DesktopName
           
        $confirm = Read-Host -Prompt "Do you want to recompose detected exceptions? Type `"Recompose`" to confirm."
    
        if ($confirm -like "recompose") {
            foreach ($Exception in $DesktopExceptionsMaster) {
                Start-HVPool -Recompose -Pool $Exception.Pool -Machines $Exception.desktopexceptions -LogoffSetting FORCE_LOGOFF -Confirm:$false
            }
        } else {
            Write-Host "Recompose not confirmed. Exiting..."
        }
    }
} else {
    Write-Host "Connection Server is empty or invalid"
    exit 1
}
