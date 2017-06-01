# count computer objects in a specified OU's

<#
$OUs = @(
    "OU=OU1,DC=Domain",
    "OU=OU2,DC=Domain"
)
#>
param([string]$OUlist)

$OUs = Get-Content "$OUlist"

foreach ($OU in $OUs) {
    $adcomputercount = get-adcomputer -filter * -searchbase "$OU" -properties canonicalname | Group-Object {($_.canonicalname -split "/")[2]}
    $OUtotal += $adcomputercount.Count
}

Write-Host "Total Computer objects: $OUtotal"
