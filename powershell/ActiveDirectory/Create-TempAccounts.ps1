param(
	[Parameter(Mandatory=$true)]
	[string]$userlist,
    [string]$OU,
    [datetime]$expirationdate = (Get-Date).AddDays(30)
)

# csv file requires name and description fields
# name is space delimited with first and last name, e.g. "John Smith"
# description can be any plain text
$users = Import-Csv $userlist

Import-Module ActiveDirectory

$user_list = @()

foreach ($user in $users) {
    $firstname_temp = $user.name.split(' ')[0]
    $lastname_temp = $user.name.split(' ')[1]
    $samaccountname_temp = $firstname_temp[0].ToString().ToLower() + $lastname_temp.ToLower() + "-temp"
    $upn_temp = $samaccountname_temp + "@contoso.com"
    $password_temp = $firstname_temp[0].ToString().ToUpper() + $lastname_temp[0].ToString().ToLower() + "randomstring"
	$user_obj_temp = New-Object PSObject -Property @{
        "Name" = $user.name
        "Username" = $samaccountname_temp
        "Password" = $password_temp
    }
    $user_list += $user_obj_temp
    $Userfields = @{        
		GivenName = $firstname_temp
		Surname = $lastname_temp
		ChangePasswordAtLogon = $true
        AccountExpirationDate = $expirationdate
		AccountPassword = ConvertTo-SecureString -String $password_temp -AsPlainText -Force
        Enabled = $true
        Description = $user.description
        DisplayName = $user.name
        Name = $user.name
        SamAccountName = $samaccountname_temp
        UserPrincipalName = $upn_temp
	}
    try {
        New-ADUser @Userfields -Path $OU -Credential (Get-Credential)
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "failed to create user for $($user.name)"
    }
}

$date = Get-Date -Format yyyy-MM-dd
$user_list | Sort-Object Name | Select-Object Name,Username,Password | Export-Csv -NoTypeInformation "accounts-$date.csv"
