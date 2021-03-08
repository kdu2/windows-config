param($IPAddress,$gateway,$dns1,$dns2)

New-NetIPAddress –IPAddress $IPAddress -DefaultGateway $gateway -PrefixLength 24 -InterfaceIndex (Get-NetAdapter).InterfaceIndex
Set-DNSClientServerAddress –InterfaceIndex (Get-NetAdapter).InterfaceIndex –ServerAddresses $dns1,$dns2
