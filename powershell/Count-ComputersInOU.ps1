# count computer objects

$OUs = @(
    "OU=DeptA,DC=Domain",
    "OU=DeptB,DC=Domain",
    "OU=DeptC,DC=Domain"
)

foreach ($OU in $OUs) {
    $total = (Get-ADComputer -filter * -searchbase $OU | Measure-Object).Count
    Write-Host "$OU`: $total"
}
