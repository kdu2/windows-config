param(
    $server="SERVER",
    $pool="POOL"
)

Import-Module vmware.hv.helper
$secpwd = Get-Content "encrypted.txt" | ConvertTo-SecureString -Key (1..32)
Connect-HVServer -Server $server -User "USER" -Password $secpwd
Start-HVPool -Pool $pool -Refresh -LogoffSetting FORCE_LOGOFF -Confirm:$false

$sendmailparams = @{
    SMTPServer = "SMTP_HOST"
    From = "SENDER_EMAIL"
    To = "RECIPIENT_EMAIL"
    Subject = "Refresh complete for $pool"
    Body = "Refresh complete for $pool"
}
Send-MailMessage @sendmailparams
