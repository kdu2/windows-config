param(
    [string]$computerlist,
    [string]$collectionname,
    [string]$limitingcollection
)

Import-Module "($env:SMS_ADMIN_UI_PATH).trimend('\i386')\ConfigurationManager.psd1"

Set-Location DIS:

try {
    New-CMDeviceCollection -Name $collectionname -LimitingCollectionName $limitingcollection
} catch {
    "Error creating collection - collection may already exist: $collectionname"
}

$computers = Get-Content $computerlist
foreach($computer in $computers) {
    try {
        Add-CMDeviceCollectionDirectMembershipRule  -CollectionName $collectionname -ResourceId $(Get-CMDevice -Name $computer).ResourceID
    } catch {
        "Invalid client or direct membership rule may already exist: $computer"
    } 
}
