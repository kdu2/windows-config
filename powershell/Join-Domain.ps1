$domain = "domain"
$OU = "OU=test,DC=domain"
$server = "server.domain"
$username = "admin"
$stdpwd = "encryptedpassword"
$secpwd = convertto-securestring $stdpwd
$cred = New-Object.System.Management.Automation.PSCredential($username,$secpwd)
$newcomputername = Read-Host -prompt "Enter computer name"
Rename-Computer -NewName $newcomputername -PassThru
Add-Computer -DomainName $domain -Credential $cred -OUPath $OU -Server $server -PassThru -Restart
