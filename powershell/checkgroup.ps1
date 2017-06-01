# check if student is in group

param([string]$ingroup,[string]$list)

$users  = Get-Content $list
$group = "*$ingroup*"
foreach($user in $users)
{
    if(!(Get-ADUser $user -Properties memberof).memberof -like $group)
    {
        Write-Output "$user is not in $ingroup" | Out-File -Append "add$ingroup.txt"
    }
}

if(!(Test-Path "add$ingroup.txt"))
{
    Write-Host "all users are in $ingroup"
}
