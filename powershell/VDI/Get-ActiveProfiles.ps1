param(
    [string]$profilepath,
    [System.DateTime]$archiveage = (Get-Date -Date 01-01-2020),
    [string]$remoteusergroup
)

$profilelist = Get-ChildItem $profilepath -Directory

$date = Get-Date -Format yyyyMMdd

Import-Module ActiveDirectory
$userlocations = @()

if (Test-Path ".\profile_vdi_user_campus_$date.csv") { Remove-Item ".\profile_vdi_user_campus_$date.csv" }
if (Test-Path ".\profile_remotepc_user_campus_$date.csv") { Remove-Item ".\profile_remotepc_user_campus_$date.csv" }

foreach ($userprofile in $profilelist) {
    if (!(Test-Path "$($userprofile.fullname)\vhd\*profiledisk.vhd")) { continue }
    $profileage = (Get-Item "$($userprofile.fullname)\vhd\*profiledisk.vhd").lastwritetime
    if ($profileage -ge $archiveage) {
        Write-Host $userprofile.name
        try {
            $userlocations += Get-ADUser $userprofile.name -Properties Office,emailaddress | Select-Object @{n="username";e={$_.samaccountname}},@{n="campus";e={$_.office}},@{n="email";e={$_.emailaddress}}
        }
        catch {
            Write-Output $user | Out-File -FilePath "c:\temp\failed_vdi_users.txt" -Append
        }    
    }
}

$RemotePCMembers = Get-ADGroupMember -Identity $remote_user_group

$remoteuserlocations = @()
foreach ($user in $RemotePCMembers) {
    try {
        $remoteuserlocations += Get-ADUser $user.samaccountname -Properties Office,emailaddress | Select-Object @{n="username";e={$_.samaccountname}},@{n="campus";e={$_.office}},@{n="email";e={$_.emailaddress}}
    }
    catch {
        Write-Output $user.samaccountname | Out-File -FilePath "c:\temp\failed_remotepc_users.txt" -Append
    }    
}

$userlocations | Export-Csv -NoTypeInformation -Path "c:\temp\profile_vdi_user_campus_$date.csv"
$remoteuserlocations | Export-Csv -NoTypeInformation -Path "c:\temp\profile_remotepc_user_campus_$date.csv"
