param([string]$vcenter,[string]$domainname)

$hosts = @(
    "foo"
    "bar"
)

$dns1 = 'x'
$dns2 = 'y'

Import-Module VMware.VimAutomation.Core

Connect-VIServer -server $vcenter -Credential (Get-Credential)

foreach ($esxhost in $hosts) {
    # use list
    Get-VMHost -Name $esxhost | Get-VMHostNetwork | Set-VMHostNetwork -DomainName $domainname -DnsAddress $dns1,$dns2 -Confirm:$false

    # set for all hosts
    #Get-VMHost | Get-VMHostNetwork | Set-VMHostNetwork -DomainName $domainname -DnsAddress $dns1,$dns2 -Confirm:$false
}
