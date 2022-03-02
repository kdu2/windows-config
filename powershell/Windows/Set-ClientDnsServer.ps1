param(
	[string]$oldDNSIP,
	[string[]]$newDNSIPs
)
$IP = Get-NetIPAddress -AddressFamily IPv4 -IPAddress "10*"
$DNSIPs = (Get-DnsClientServerAddress -InterfaceIndex $IP.InterfaceIndex -AddressFamily IPv4).ServerAddresses
if ($DNSIPs -contains $oldDNSIP) {
	Write-Host "Testing DNS lookup" -ForegroundColor Green
	$dnstest = Resolve-DnsName -Name google.com -Server $newDNSIP[0] -Type A
	$dnstest
	if ($dnstest) {
		$netadapter = Get-NetAdapter -InterfaceIndex $IP.InterfaceIndex
		Write-Host "Updating DNS on network adapter settings" -ForegroundColor Green
		$netadapter | Select-Object InterfaceAlias,InterfaceDescription | Format-Table
		Set-DnsClientServerAddress -InterfaceIndex $IP.InterfaceIndex -ServerAddresses $newDNSIPs
		Write-Host "DNS servers updated" -ForegroundColor Green
		Get-DnsClientServerAddress -InterfaceIndex $IP.InterfaceIndex -AddressFamily IPv4 | Select-Object InterfaceAlias,ServerAddresses | Format-Table
	} else {
		Write-Host "Failed to reach $($newDNSIP[0])" -ForegroundColor Red
	}
}