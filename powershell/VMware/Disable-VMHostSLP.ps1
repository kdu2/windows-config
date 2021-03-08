param(
    [string]$vcenter,
    [string]$hostprefix
)

$modules = Get-Module

if ($modules -notcontains "vmware.vimautomation.core") { Import-Module vmware.vimautomation.core }

if (!$global:DefaultVIServer) { Connect-VIServer -server $vcenter -Credential (Get-Credential) }

$hosts = Get-VMHost -Name "$hostprefix*"
$esxipwd = Read-Host -AsSecureString
$esxicred = New-Object System.Management.Automation.PSCredential('root',$esxipwd)

foreach ($vmhost in $hosts){
    Write-Host -ForegroundColor Blue -NoNewline "$($vmhost.name)"
    if((Get-VMHostService -VMHost $vmhost).where({$_.Key -eq 'TSM-SSH'}).Running){
        Write-Host -ForegroundColor Green " SSH running"
        $ssh = New-SSHSession -ComputerName $vmhost.name -Credential $esxicred -AcceptKey -KeepAliveInterval 5
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("/etc/init.d/slpd status") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("/etc/init.d/slpd stop") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("/etc/init.d/slpd status") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("chkconfig slpd") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("esxcli network firewall ruleset set -r CIMSLP -e 0") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("chkconfig slpd off") -TimeOut 30 | Select-Object -ExpandProperty Output
        Invoke-SSHCommand -SessionId $ssh.SessionId -Command ("chkconfig slpd") -TimeOut 30 | Select-Object -ExpandProperty Output
        Remove-SSHSession -SessionId $ssh.SessionId | Out-Null        
    }
}
