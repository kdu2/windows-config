param ([string]$server)

Import-Module vmware.vimautomation.core

Connect-VIServer -Server $server -Credential (Get-Credential)

Get-VM -Location ClonePrepInternalTemplateFolder | Sort-Object name | Select-Object name | ExportTo-Csv -NoTypeInformation | Out-file c:\temp\cp-template.txt
