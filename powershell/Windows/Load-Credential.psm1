function Load-Credential {
    param (
        [Parameter(Mandatory=$true)]
        [string]$username
    )

    $secpwd = Read-Host -AsSecureString -Prompt "Enter password"
    $cred = New-Object System.Management.Automation.PSCredential ($username,$secpwd)

    return $cred
}