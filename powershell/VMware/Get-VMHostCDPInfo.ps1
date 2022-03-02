param([string]$VMHost)

$vmh = Get-VMHost $VMHost
if ($vmh.ConnectionState -ne "Connected") {
    Write-Output "Host $($vmh) state is not connected, skipping."
} else {
    Get-View $vmh.ID |
    foreach { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem } |
    foreach { foreach ($physnic in $_.NetworkInfo.Pnic) {
        $pnicInfo = $_.QueryNetworkHint($physnic.Device)
        foreach ($hint in $pnicInfo) {
            # Write-Host $esxname $physnic.Device
            if ( $hint.ConnectedSwitchPort ) {
                $hint.ConnectedSwitchPort | Select-Object @{n="VMNic";e={$physnic.Device}},DevId,Address,PortId,HardwarePlatform
            } else {
                Write-Host "No CDP information available."
            }
        }
    }}
}
