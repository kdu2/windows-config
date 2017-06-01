# check for disconnected NICS to fix "agent unreachable" status in View Administrator console

Add-PSSnapin vmware.vimautomation.core

Connect-VIServer vcenterserver

for ($i = 1; $i -le 150; $i++)
{
    $linkedclone = "A001LAB-" + $i.ToString() + "V"

    Get-NetworkAdapter -VM $linkedclone -Name "Network adapter 1" | Set-NetworkAdapter -Connected:$true -Confirm:$false
    Write-Output "Reconnected network adapter on VM $linkedclone" | Out-File -Append "NIC-reconnect.log"
}
