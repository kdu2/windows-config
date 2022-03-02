param(
    [Parameter(Mandatory=$true)]
    [string[]]$vmhosts,
    [Parameter(Mandatory=$true)]
    [string]$vswitch
    [Parameter(Mandatory=$true)]
    [string]$dvswitch
)

foreach ($vmhost in $vmhosts) {
    $VMs = Get-VM -VirtualSwitch (Get-VirtualSwitch -Name $vswitch -VMHost $vmhost) | Where-Object { (Get-NetworkAdapter $_ | Measure-Object).count -eq 1 -and ((Get-NetworkAdapter $_).NetworkName -notlike "DVlan*") | Sort-Object -Property Name -Descending }
    
    foreach ($VM in $VMs) {
        Write-Host "$($vm.name)" -Foregroundcolor Cyan
        $vlan = (Get-VirtualPortGroup -VM $VM.name).vlanid
        try {
            if ($vlan) {
                $portgroup = Get-VirtualPortGroup -VirtualSwitch $dvswitch -Name "DVlan$vlan"
                if ($portgroup) {
                    Write-Host "Setting network on $($vm.name) from `"$(Get-VirtualPortGroup -VM $VM.name)`" to `"$($portgroup.name)`"" -Foregroundcolor Green
                    Set-NetworkAdapter -NetworkAdapter (Get-NetworkAdapter -VM $VM.name) -Portgroup $portgroup.name -Whatif                    
                }
            }        
        } catch {
            Write-Host "Portgroup not found on $dvswitch"
        }
    }
}
