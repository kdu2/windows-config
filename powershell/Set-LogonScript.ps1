# change logon script for users based on OU

# input parameter is user OU in LDAP format. e.g. "OU=Path,DC=Domain"
param([string]$OU)

# filter based on OU and set the logon script name (defaults to netlogon as path)
Get-ADUser -Filter * -SearchBase $OU | Set-ADUser -scriptPath "loginscript.bat"
