param([string]$list)

$users = Get-Content -Path $list

Import-Module ActiveDirectory

$userlocations = @()

foreach ($user in $users) {
    try {
        $userlocations += Get-ADUser $user -Properties Office,emailaddress | Select-Object @{n="username";e={$_.samaccountname}},@{n="campus";e={$_.office}},@{n="email";e={$_.emailaddress}}
    }
    catch {
        Write-Output $user | Out-File -FilePath "c:\temp\failed_users.txt" -Append
    }    
}

$userlocations | Export-Csv -NoTypeInformation -Path c:\temp\profile_user_campus.csv
