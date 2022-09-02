param(
    [Parameter(Mandatory=$true)]
    [string]$ConnectionServer
)

Import-Module vmware.hv.helper
Connect-HVServer -Server $ConnectionServer
$pools = Get-HVPool

$PoolList = @()
$date = Get-Date -Format yyyy-MM-dd

foreach ($pool in $pools) {
    $obj = New-Object PSObject -Property @{
        "Name" = $pool.base.Name
        "DisplayName" = $pool.base.displayname
        "Entitlements" = [string](Get-HVEntitlement -ResourceName $pool.base.name).base.displayname
        "ParentVM" = $pool.AutomatedDesktopData.VirtualCenterNamesData.ParentVmPath | Split-Path -Leaf
        "Snapshot" = $pool.AutomatedDesktopData.VirtualCenterNamesData.SnapshotPath
        "desktoptotal" = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.MaxNumberOfMachines
        "vmprefix" = $pool.AutomatedDesktopData.VmNamingSettings.PatternNamingSettings.NamingPattern
    }
    $PoolList += $obj
}
$PoolList | Sort-Object ParentVM | Select-Object name,Entitlements,vmprefix,desktoptotal,ParentVM,Snapshot | Export-Csv -NoTypeInformation "C:\temp\$connectionserver-poolinfo-$date.csv"
$PoolList | Sort-Object ParentVM | Select-Object name,Entitlements,vmprefix,desktoptotal,ParentVM,Snapshot
