param(
    $server = "SERVER",
    $pool = "POOL",
    $domain = "domainfqdn",
    $username = "user"
)

Import-Module vmware.hv.helper
$secpwd = Get-Content "encrypted.txt" | ConvertTo-SecureString -Key (1.32)
Connect-HVServer -Server $server -User "USER" -Password $secpwd

$kiosksessions = Get-HVLocalSession | Where-Object { $_.NamesData.UserName -eq "$domain\$username" }

$desktops = @()

foreach ($session in $kiosksessions) {
    $desktops += $session.NamesData.MachineOrRDSServerName
}

Start-HVPool -Refresh -Pool $pool -Machines $desktops -LogoffSetting FORCE_LOGOFF -Confirm:$false

$sendmailparams = @{
    SMTPServer = "SMTP_HOST"
    From = "SENDER_EMAIL"
    To = "RECIPIENT_EMAIL"
    Subject = "Refresh complete for $username in $pool"
    Body = "Refresh complete for $username in $pool"
}
Send-MailMessage @sendmailparams
