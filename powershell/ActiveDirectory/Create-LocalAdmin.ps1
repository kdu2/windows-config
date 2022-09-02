param(
	[Parameter(Mandatory=$true)]
	[string]$userlist
)

$users = Import-Csv $userlist

$OU = "OU=Example,DC=domain,DC=com"

Import-Module ActiveDirectory

foreach ($user in $users) {
	$Userfields = @{		
		GivenName = $user.Firstname
		Surname = $user.LastName
		Department = "DEPT"
		Company = "COMPANY"
        ChangePasswordAtLogon = $true
		AccountPassword = ConvertTo-SecureString -String $user.password -AsPlainText -Force
        Enabled = $true
        Description = $user.description
        DisplayName = $user.name
        Name = $user.name
        SamAccountName = $user.samaccountname
        UserPrincipalName = $user.Upn
	}
	New-ADUser @Userfields -Path $OU -Credential (Get-Credential)
}

foreach ($user in $users) {
	Add-ADGroupMember -Identity "Local Admins" -Members $user.samaccountname -Credential $cred
}
