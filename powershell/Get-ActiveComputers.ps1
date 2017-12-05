# get list of computers that have been logged into in the past 90 days

$workstations = @()

# change root path as needed for your domain
$rootOU = "OU=Workstations,DC=Domain"

# change OU list as needed
$OUs = @(
    "OU=DeptA",
    "OU=DeptB",
    "OU=DeptC"
)

foreach ($OU in $OUs) {
    $workstations += Get-ADComputer -Filter '*' -SearchBase "$OU,$rootOU" -SearchScope OneLevel -Properties lastlogondate,operatingsystem | `
        where { $_.lastlogondate -ge (Get-Date).AddDays(-90) } | select name,operatingsystem,lastlogondate
}

$workstations | Export-Csv ActiveWorkstations.csv -NoTypeInformation
