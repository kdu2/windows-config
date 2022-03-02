param([string]$userlist="$env:userprofile\desktop\accounts.txt")

$accounts = Get-Content $userlist
Add-Type -AssemblyName 'System.Web'

foreach ($account in $accounts) {
    $pw = [System.Web.Security.Membership]::GeneratePassword(20, 1)
    Write-Host "Resetting password for $account"
    Set-ADAccountPassword -Identity $account -Reset -NewPassword (ConvertTo-Securestring -AsPlainText "$pw" -Force)
    Write-Host "Disabling account for $account"
    Disable-ADAccount -Identity $account
}
