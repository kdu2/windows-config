param(
    [Parameter(Mandatory=$true)]
    [string]$zone,
    [Parameter(Mandatory=$true)]
    [string]$server,
    [Parameter(Mandatory=$true)]
    [string]$subnet
)

$dnslist = Get-DnsServerResourceRecord -ZoneName "$zone"  -RRType 'A'  -ComputerName "$server" | Where-Object { $_.recorddata.ipv4address -like "$subnet*" }

$dns_obj = @()

foreach ($entry in $dnslist) {
    $dns_temp = New-Object PSObject -Property @{
        "hostname" = $entry.hostname
        "ipaddress" = $entry.recorddata.ipv4address.ipaddresstostring
    }
    $dns_obj += $dns_temp
}
$dns_obj | Select-Object hostname,ipaddress | Sort-Object ipaddress | Export-Csv -NoTypeInformation -Path .\dns.csv
