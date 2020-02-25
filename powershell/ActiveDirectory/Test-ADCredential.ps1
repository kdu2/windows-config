<#
.Synopsis
Verify Active Directory credentials

.DESCRIPTION
This function takes a user name and a password as input and will verify if the combination is correct. The function returns a boolean based on the result.

.NOTES   
Name: Test-ADCredential
Original Author: Jaap Brasser
Maintainer: kdu2
Version: 1.1
Updated: 2018-10-26

.PARAMETER UserName
The samaccountname of the Active Directory user account
	
.PARAMETER Password
The password of the Active Directory user account

.EXAMPLE
Test-ADCredential -username jaapbrasser


Description:
Verifies if the username and password provided are correct, returning either true or false based on the result
#>
function Test-ADCredential {
    [CmdletBinding()]
    param([String]$UserName)
    
    if (!($UserName)) {
        $UserName = Read-Host -Prompt "Enter username"
    }
    if (!($Password)) {
        $SecurePassword = Read-Host -Prompt "Enter password" -AsSecureString
        $Password = (New-Object PSCredential "user",$SecurePassword).GetNetworkCredential().Password
    }

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('domain')
    $CredentialTest = $DS.ValidateCredentials($UserName, $Password)
    if ($CredentialTest) {
        Write-Host "Password is correct!"
    } else {
        Write-Host "Password is incorrect!"
    }
}
