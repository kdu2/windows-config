param([string]$ConnectionServer)

if ($null -ne $ConnectionServer) {
    Import-Module vmware.hv.helper
    Connect-HVServer -Server $ConnectionServer
    $pools = Get-HVPool

    $PoolList = @()

    foreach ($pool in $pools) {
        $obj = New-Object PSObject -Property @{
            "Name" = $pool.base.Name
            "DisplayName" = $pool.base.displayname
            "ParentVM" = $pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath | Split-Path -Leaf
            "Snapshot" = $pool.AutomatedDesktopData.VirtualCenterNamesData.SnapshotPath
            "desktoptotal" = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.MaxNumberOfMachines
            "vmprefix" = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.NamingPattern
        }
        $PoolList += $obj
    }
    $PoolList | Sort-Object ParentVM | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot | Export-Csv -NoTypeInformation "C:\temp\poolinfo.csv"
    $PoolList | Sort-Object ParentVM | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot
} else {
    Write-Host "`$ConnectionServer is blank. Please re-run script with valid parameter."
}
