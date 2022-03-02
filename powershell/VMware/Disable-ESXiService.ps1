param(
    [string]$vcenter,
    [string]$service
)

Import-Module vmware.vimautomation.core

if(!$global:defaultviservers) {
    Write-Host "No vCenter Server specified."
    Connect-VIServer -Server $vcenter -Credential (Get-Credential) }

$vmhosts = Get-VMHost

if (!$service) {
    Write-Host "No service selected. Please run the script again specifying one of the services below:"
    Get-VMHostService $vmhost[0] | Select-Object Label
}

foreach ($vmhost in $vmhosts) {
    $CIM = Get-VMHost $vmhost | Get-VMHostService | Where-Object { $_.label -eq "$service" -and $_.running -eq "True" }
    if ($CIM) {
        Write-Host "Disabling $service on $($vmhost.name)"
        $CIM | Stop-VMHostService -Confirm:$false
        $CIM | Set-VMHostService -Policy Off 
    }    
}
