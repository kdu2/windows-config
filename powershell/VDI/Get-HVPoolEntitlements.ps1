param(
    [Parameter(Mandatory=$true)]
    [string]$connectionserver
)

Import-Module vmware.hv.helper
Connect-HVServer -Server $connectionserver

$pools = Get-HVPool

$entitlements = @()

foreach ($pool in $pools) {
    $obj = New-Object PSObject -Property @{
        "Name" = $pool.base.name
        "Entitlements" = [string](Get-HVEntitlement -ResourceName $pool.base.name).base.DisplayName
    }
    $entitlements += $obj
}

$entitlements | Sort-Object Name | Select-Object Name,Entitlements | Export-Csv -NoTypeInformation "C:\temp\$connectionserver-poolentitlements.csv"
$entitlements | Sort-Object Name | Select-Object Name,Entitlements
