# change logon script for users based on OU

# input parameter is user OU in LDAP format. e.g. "OU=User,OU=Accounts,DC=Domain"
param([string]$OU,[string]$group)

# set prefix OU
$fullOU = "OU=" + $OU + ",OU=Path,DC=Domain"

Get-ADUser -Filter * -SearchBase $fullOU | foreach-object{
    
    Remove-ADGroupmember -Identity $group -Members $($_.samaccountname) -Confirm:$false -ErrorAction SilentlyContinue
}
