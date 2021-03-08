param(
    [String]$DatastoreList,
    [String]$ESXiHost
)

Import-Module VMware.VimAutomation.Core

$Datastores = Get-Content $DatastoreList

$secpwd = Read-Host -AsSecureString
$esxicred = New-Object System.Management.Automation.PSCredential("root", $secpwd)
Connect-VIServer -Server $ESXiHost -Credential $esxicred

Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -1 -Scope Session -Confirm:$false
$ESXHost = Get-VMHost
Write-Host "Connecting via esxcli to $VMHost" -ForegroundColor Green
$esxcli = Get-EsxCli -VMHost $ESXHost -V2
foreach ($Datastore in $Datastores) {
    $DatastoreName = Get-Datastore $Datastore
    Write-Host "Unmapping $Datastore on $VMHost" -ForegroundColor Green
    $esxcli.storage.vmfs.unmap($null,$DatastoreName,$null)
}
