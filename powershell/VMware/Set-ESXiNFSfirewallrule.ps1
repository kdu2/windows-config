param([String]$vcenter,[string]$vcenteradmin,[string]$nfsIPs)

Import-Module VMware.VimAutomation.Core

$secpwd = Read-Host -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($vcenteradmin,$secpwd)
Connect-VIServer -Server $vcenter -Credential $cred

Set-PowerCLIConfiguration -WebOperationTimeoutSeconds -1 -Scope Session -Confirm:$false
$ESXHosts = Get-VMHost
foreach ($ESXHost in $ESXHosts) {
    Write-Host "Enabling firewall exception on $ESXHost"
    Get-VMHostFirewallException -VMHost $ESXHost -Name "NFS Client" | Set-VMHostFirewallException -Enabled $true
    Write-Host "Connecting via esxcli to $ESXHost" -ForegroundColor Green
    $esxcli = (Get-EsxCli -VMHost $ESXHost -V2).network.firewall
    Write-Host "Setting NFS firewall rule on $VMHost" -ForegroundColor Green
    $esxcli.ruleset.rule.set($false,$true,"nfsClient")
    $esxcli.ruleset.allowedip.add($nfsIPs,"nfsClient")
}
