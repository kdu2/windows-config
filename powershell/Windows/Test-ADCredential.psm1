function Test-ADCredential {
    [CmdletBinding()]
    param(
        [String]$UserName,
        [String]$Domain
    )
    
    if (!($UserName)) {
        $UserName = Read-Host -Prompt "Enter username"
    }
    if (!($Domain)) {
        $Domain = Read-Host -Prompt "Enter Domain"
    }
    if (!($Password)) {
        $SecurePassword = Read-Host -Prompt "Enter password" -AsSecureString
        $Password = (New-Object PSCredential "user",$SecurePassword).GetNetworkCredential().Password
    }

    Add-Type -AssemblyName System.DirectoryServices.AccountManagement
    $ctype = [System.DirectoryServices.AccountManagement.ContextType]::Domain
    $DS = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext($ctype,$Domain)
    $CredentialTest = $DS.ValidateCredentials($UserName, $Password)
    if ($CredentialTest) {
        Write-Host "Password is correct!"
    } else {
        Write-Host "Password is incorrect!"
    }
}