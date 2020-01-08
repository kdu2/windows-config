# script to extract MAC addresses from list of computers

# specify pool prefix and number of vm's
param([string]$prefix,[int]$max)

$machines = @()
for ($i = 1; $i -le $max; $i++) {
    $machines += "$prefix-$($i.ToString("00"))v"
}    

$date = Get-Date -Format "MM-dd-yyyy"

Write-Host "Getting MAC addresses"
foreach ($machinename in $machines) {
    Write-Host $machinename
    #get-wmiobject win32_networkadapterconfiguration -computer $machinename -filter "IPEnabled='True'" | Where {($_.macaddress -ne "00:50:56:C0:00:01") -and ($_.macaddress -ne "00:50:56:C0:00:08")} | Select DNSHostname,MACAddress  | Export-Csv -append "$pool-macaddress-$date.csv"
    get-wmiobject win32_networkadapter -computer $machinename -filter "name='vmxnet3 Ethernet Adapter'" | Select SystemName,MACAddress  | Export-Csv -append "$prefix-macaddress-$date.csv" -NoTypeInformation
}
