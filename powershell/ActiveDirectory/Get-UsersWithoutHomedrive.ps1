Import-Module ActiveDirectory

$searchbases = @(
    "OU1",
    "OU2"
)

foreach ($type in $searchbases) {
    Get-ADUser -Filter * -SearchBase "OU=$type,DC=domain" -Properties * | where { $_.homedirectory -eq $null } | select samaccountname,office | ConvertTo-Csv -NoTypeInformation | sort office,samaccountname | Set-Content "$type.csv"
}
