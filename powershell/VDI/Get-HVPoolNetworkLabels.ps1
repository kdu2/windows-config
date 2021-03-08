param([string]$ConnectionServer)

Import-Module vmware.hv.helper
Connect-HVServer -Server $ConnectionServer
$pools = Get-HVPool

$PoolList = @()

foreach ($pool in $pools) {
    $obj = New-Object PSObject -Property @{
        "Name" = $pool.base.Name
        "DisplayName" = $pool.base.displayname
        "NicNames" = $pool.AutomatedDesktopData.VirtualCenterNamesData.NicNames
        "NetworkLabelNames" = $pool.AutomatedDesktopData.VirtualCenterNamesData.NetworkLabelNames
    }
    $PoolList += $obj
}
$PoolList | Sort-Object ParentVM | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot,Labels | Export-Csv -NoTypeInformation "C:\temp\poolinfo.csv"
$PoolList | Sort-Object ParentVM | Select-Object name,vmprefix,desktoptotal,ParentVM,Snapshot,Labels
