param(
    [string]$vcenter,
    [string]$toolsversion = "10.3.10"
    )

Import-Module vmware.vimautomation.core

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

$guests = Get-VM | Where-Object { ($_.Guest.ConfiguredGuestId -like "win*") -and ($_.Guest.ToolsVersion -ne $toolsversion) }

$guests | Sort-Object name | Select-Object name,powerstate,@{n='version';e={$_.guest.toolsversion}},@{n='OS';e={$_.guest.osfullname}} | Export-Csv -NoTypeInformation -Path c:\temp\outdated.csv
