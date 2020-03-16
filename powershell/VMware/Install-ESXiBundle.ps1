param(
    [string]$VMHost,
    [string]$LocalPath,
    [string]$Bundle,
    [string]$DatastoreName,
    [string]$UploadFolder
)

# Upload Patch
$Datastore =  Get-Datastore -Name $DatastoreName
New-PSDrive -Name ds -PSProvider VimDatastore -Root '\' -Datastore $Datastore | Out-Null
Copy-DatastoreItem -Item "$LocalPath\$Bundle" -Destination "ds:\$UploadFolder\"
Remove-PSDrive -Name ds

# Install Host Patch
$HostPath = "/vmfs/volumes/$DatastoreName/$Bundle"
$esxcli2 = Get-ESXCLI -VMHost $VMhost -V2
$CreateArgs = $esxcli2.software.vib.install.CreateArgs()
$CreateArgs.depot = $HostPath
$InstallResponse = $esxcli2.software.vib.install.Invoke($CreateArgs)

# Restart Host
if ($InstallResponse.RebootRequired -eq $true) {
    Write-Host "Rebooting '$($VMHost.Name)'..."
    Write-Host "VIBs Installed:"
    $InstallResponse.VIBsInstalled

    $VMhost | Restart-VMHost -Confirm:$false | Out-Null    
} else {
    Write-Host "No Reboot for '$($VMHost.Name)' required..."    
}
