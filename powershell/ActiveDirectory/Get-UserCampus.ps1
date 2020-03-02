param([string]$list)

$users = Get-Content -Path $list

Import-Module ActiveDirectory

$userlocations = @()

foreach ($user in $users) {
    try {
        $userlocations += Get-ADUser $user -Properties Office | Select-Object @{n="username";e={$_.samaccountname}},@{n="campus";e={$_.office}}    
    }
    catch {
        Write-Output $user | Out-File -FilePath "c:\temp\failed_users.txt" -Append
    }    
}

$userlocations | Export-Csv -NoTypeInformation -Path c:\temp\profile_user_campus.csv
