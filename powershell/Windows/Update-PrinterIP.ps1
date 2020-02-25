#function Update-PrinterPort {
Param(
    $computerlist,
    $IPlist
)

$computers = Get-Content $computerlist
$IPs = Import-Csv $IPlist

foreach ($computer in $computers) {
    Write-Host "Checking $computer"
    foreach ($ip in $IPs) {
        $port = Get-WmiObject -class win32_tcpipprinterport -ComputerName $computer -Property * | where { $_.HostAddress -eq $ip.OldIP }

        $old_port_name = $port.name
        Write-Host "$computer has a port on $($ip.OldIP) named $old_port_name"
        New-Printerport -gpp_ip_address $ip.NewIP -computername $computer
        Write-Host "A new port was made it's name and IP address are both $($ip.NewIP)"
        if ($printer = Get-WmiObject -class win32_printer -ComputerName $computer -Property * | where Portname -eq $old_port_name) {
            Write-Host "$computer has a printer attached to $old_port_name"
            $printer.Portname = "$($ip.NewIP)"
            Write-Host "now it is set to $($printer.PortName)"
            $printer.put()
            Write-Host "and the setting is written to the WMI"
        }
    }
}
#}

function New-Printerport {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $GPP_IP_Address,
        $computername
    )

    $port = [wmiclass]"\\$computername\ROOT\cimv2:Win32_TcpIpPrinterPort"
    $port.psbase.scope.options.EnablePrivileges = $true
    $newPort = $port.CreateInstance()
    $newport.name = "$GPP_IP_Address"
    $newport.Protocol = 1
    $newport.HostAddress = $GPP_IP_Address
    $newport.PortNumber = "9100"
    $newport.SnmpEnabled = $false
    $newport.Put()
}
