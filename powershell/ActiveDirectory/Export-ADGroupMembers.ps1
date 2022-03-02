param(
    [Parameter(Mandatory=$true)]
    [string]$GroupList,
    [Parameter(Mandatory=$true)]
    [string]$DomainController
)

$groups = Get-Content $GroupList

if (!(Get-Module ActiveDirectory)) { Import-Module ActiveDirectory }

$users_obj = @()
    
foreach ($group in $groups) {
    $users = (Get-ADGroup -Identity $group -Property members -Server "$($DomainController):3268").members

    foreach ($cn in $users) {
        $user = Get-ADUser -Identity $cn -Properties emailaddress,displayname -Server "$($DomainController):3268"
        $user_temp = New-Object PSObject -Property @{
            "Email" = $user.emailaddress
            "DisplayName" = $user.displayname
            "Group" = $group
        }
        $users_obj += $user_temp
    }
    $users_obj | Sort-Object -Property Group,DisplayName | ConvertTo-Csv -NoTypeInformation | Out-File c:\temp\groups.csv -Encoding ascii
}
