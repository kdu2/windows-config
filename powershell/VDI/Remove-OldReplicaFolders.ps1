param([string]$vcenter="vcenter")

Import-Module VMware.VimAutomation.Core

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

$replicadatastores = @(
    "REPLICA01"
    "REPLICA02"
    "REPLICA03"
    "REPLICA04"
    "REPLICA05"
)

$oldreplicas = @()

foreach ($datastore in $replicadatastores) {
    $vdatastore = Get-Datastore -Name $datastore
    $VMs = @()
    Get-VM -Datastore $vdatastore -Name "replica*" | foreach { $VMs += $_.Name }
    New-PSDrive -Name vds -Location $vdatastore -PSProvider VimDatastore -Root '\' | Out-Null
    $VMfolders = Get-ChildItem -Path vds: -Filter "replica*"
    foreach ($replica in $VMfolders) {
        if ($VMs -notcontains $replica.name) {
            $oldreplicas += $replica.name
        }
    }
}

if (!(Test-Path c:\temp)) { New-Item -Path c:\temp -ItemType Directory }
$oldreplicas | Export-Csv -NoTypeInformation -Path c:\temp\oldreplicas.csv
