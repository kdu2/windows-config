parama([string]$classroom)

$machines = Get-Content "$classroom.txt"
foreach($machinename in $machines)
{
    get-wmiobject win32_networkadapterconfiguration -computer $machinename -filter "IPEnabled='True'" | foreach-object {New-Object PSObject -Property @{"DNSHostname" = $machine, "IPAddress" = $_.IPAddress[0]}} | select DNSHostname,IPAddress | export-csv -append "$classroom-ipaddress.csv"
}