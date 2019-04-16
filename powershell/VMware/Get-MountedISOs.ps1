param([Parameter(Mandatory=$true)][string]$vcenterserver)

if (!(Get-Module "vmware.vimautomation.core")) {
    Import-Module "vmware.vimautomation.core"
}

Connect-VIServer $vcenterserver

$VMs = Get-VM | Format-Table name, @{Label="ISO"; expression = { ($_ | Get-CDDrive).IsoPath }} | Where-Object { $_.ISO -ne $null }

$VMs | Sort-Object name | Export-Csv -NoTypeInformation -Path ".\VDI-ISO`'s.csv"
