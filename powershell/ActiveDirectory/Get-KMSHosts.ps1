param(
    [Parameter(Mandatory=$true)]
    [string]$zone,
    [Parameter(Mandatory=$true)]
    [string]$server
)

$dnslist = Get-DnsServerResourceRecord -ZoneName "$zone"  -RRType 'Srv' -Name '_VLMCS._tcp' -ComputerName "$server"

$dns_obj = @()

foreach ($entry in $dnslist) {
    $dns_temp = New-Object PSObject -Property @{
        "hostname" = $entry.recorddata.domainname.trimend(".$zone.")
    }
    $dns_obj += $dns_temp
}
$dns_obj | Sort-Object | Export-Csv -NoTypeInformation -Path c:\temp\kms.csv
