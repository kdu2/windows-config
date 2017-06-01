# count computer objects in a specified OU

param([String]$searchOU="CN=Computers")

$searchOU = "$searchOU,DC=Domain"

$adcomputercount = get-adcomputer -filter * -searchbase "$searchOU" -properties canonicalname | Group-Object {($_.canonicalname -split "/")[2]}

$OUtotal = $adcomputercount.Count

Write-Host "Total Computers in this OU: $OUtotal"
