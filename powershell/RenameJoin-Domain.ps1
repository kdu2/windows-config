# renames computer and joins coast domain

# prompt for new computer name
$newname = Read-Host -Prompt "Enter new computer name:"

# rename computer
wmic computersystem where name=$env:computername call rename name=$newname

# join domain and restart computer
$credential = New-Object System.Management.Automation.PsCredential("domain\user", (ConvertTo-SecureString "password" -AsPlainText -Force))
Add-Computer -DomainName "domain" -ComputerName $newname -Credential $credential
Restart-Computer
