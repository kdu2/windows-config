$credential = New-Object System.Management.Automation.PsCredential("domain\user", (ConvertTo-SecureString "password" -AsPlainText -Force))
Add-Computer -DomainName "domain" -Credential $credential
Restart-Computer
