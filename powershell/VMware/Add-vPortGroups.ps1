param([string]$vswitch)
$vlans = @(
    123
    456
    789
)

$VMHosts = @(
    "vmhost1"
    "vmhost2"
    "vmhost3"
)

foreach ($vmhost in $vmhosts) {
    $vswitch = Get-VirtualSwitch -VMHost $vmhost -Name $vswitch
    foreach ($vlan in $vlans) {
        New-VirtualPortGroup -VirtualSwitch $vswitch -VLanId $vlan -Name "Vlan$vlan"
    }
}
