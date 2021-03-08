param([string]$vcenter)

Import-Module vmware.vimautomation.core

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

$vmhosts = Get-VMHostStorage | Select-Object VMHost,ScsiLun

$stor0 = $vmhosts.scsilun | Select-Object vmhost, canonicalname,capacitygb | Where-Object { $_.capacityGB -eq 0 }

$stor0 | Export-Csv -NoTypeInformation -Path c:\temp\storagedeviceszero.csv
