# script to extract MAC addresses from computers loaded from a text list

# specify classroom (name of file.txt)
param([string]$classroom)

$machines = Get-Content "$classroom.txt"
$date = Get-Date -Format "MM-dd-yyyy"

foreach($machinename in $machines)
{
    get-wmiobject win32_networkadapterconfiguration -computer $machinename -filter "IPEnabled='True'" | Where {($_.macaddress -ne "00:50:56:C0:00:01") -and ($_.macaddress -ne "00:50:56:C0:00:08")} | Select DNSHostname,MACAddress  | Export-Csv -append "$classroom-macaddress-$date.csv"
    #get-wmiobject win32_networkadapter -computer $machinename -filter "name='vmxnet3 Ethernet Adapter'" | Select DNSHostname,MACAddress  | Export-Csv -append "$classroom-macaddress-$date.csv"
}
