param($vcenter,$datastore)

Import-Module vmware.vimautomation.core
Import-Module Posh-SSH

Connect-VIServer -Server $vcenter

Get-VMHost | Get-AdvancedSetting -Name "UserVars.ProductLockerLocation" | Set-AdvancedSetting -Value "/vmfs/volumes/$datastore/vmtools" -Confirm:$false

$hosts = Get-VMHost | Select-Object Name
$esxipwd = Read-Host -AsSecureString
$esxicred = New-Object System.Management.Automation.PSCredential('root',$esxipwd)

foreach ($server in $hosts) {
    $ssh = New-SSHSession -ComputerName $vmhost.name -Credential $esxicred -AcceptKey -KeepAliveInterval 5
    Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("rm /productLocker") -TimeOut 30 | Select-Object -ExpandProperty Output
    Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("ln -s /vmfs/volumes/$datastore/vmtools /productLocker") -TimeOut 30 | Select-Object -ExpandProperty Output
}
