param(
    [Parameter(Mandatory=$true)]
    [string]$collection,
    [Parameter(Mandatory=$true)]
    [string]$site
)

Import-Module ($env:SMS_ADMIN_UI_PATH).trimend('\i386')

Set-Location "$site`:"

Get-CMCollectionMember -CollectionName $collection | Sort-Object Name | Select-Object name | Export-Csv -Path  'c:\logs\collection.csv' -NoTypeInformation
