# shutdown all vm's in desktop pool

param([string]$prefix,[string]$vcenter)

if ($prefix -eq $null) {
    Write-Host "Pool not specified."
    exit 1
}

Import-Module VMware.VimAutomation.Core

Connect-VIServer $vcenter

Get-VM -Name "$prefix*" | Where-Object { $_.PowerState -eq "PoweredOn" } | Shutdown-VMGuest
