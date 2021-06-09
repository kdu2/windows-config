param(
    $dhcpserver,
    $subnet
)

$data = (netsh dhcp server $dhcpserver scope $subnet show clients 1)

#start by looking for lines where there is both IP and MAC present:
$lines = @()
foreach ($i in $data){
    if ($i -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"){
        If ($i -match "[0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}[:-][0-9a-f]{2}"){    
            $lines += $i.Trim()
        }
    }
}

$lines

$results = @()
foreach ($l in $lines){
    $Row = "" | select IP, Subnet, MAC, Hostname
    $Row.IP = ($l.substring(0,16)).replace(" ","")
    $Row.subnet = ($l.substring(18,15)).replace(" ","")
    $Row.MAC = ($l.substring(35,20)).replace(" ","")
    $Row.Hostname = ($l.substring(84)).replace(" ","")    
    $results += $Row
}

# Create a csv file
$results | sort-object Hostname | Export-Csv "dhcp-data.csv"
