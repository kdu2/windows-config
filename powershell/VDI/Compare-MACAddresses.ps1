# compare mac addresses of pool after recompose

# 1st argument is old mac address csv file, 2nd argument is new mac address csv file
param([string]$oldcsv,[string]$newcsv)

$oldmac = Import-Csv -Path $oldcsv
$newmac = Import-Csv -Path $newcsv

$subnet = "10.0.1."

$differences=@()

for ($i = 1; $i -le 44; $i++) {
    if (($oldmac[$i].DNSHostname -eq $newmac[$i].DNSHostname) -and ($oldmac[$i].MACAddress -ne $newmac[$i].MACAddress)) {
        $octet = (199+$i).ToString()
        $ip = $subnet+$octet
        Write-Output "$ip | $($newmac[$i].MACAddress) | $($newmac[$i].DNSHostname)" | Out-File -Append "macaddressdifferences.txt"
    }    
}
