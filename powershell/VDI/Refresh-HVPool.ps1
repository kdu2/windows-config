param(
    $server="SERVER",
    $pool="POOL"
)

Import-Module vmware.hv.helper
Connect-HVServer -Server $server
Get-HVPool -PoolName $pool | Start-HVPool -Refresh -LogoffSetting FORCE_LOGOFF -Confirm:$false

$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "SMTP_HOST"                    # Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "SENDER_EMAIL"      # Change to email address you want emails to be coming from
$MailMessage.To.add("RECIPIENT_EMAIL")     # Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Refresh complete for $pool"   # Change to set your email subject
$MailMessage.Body = "Refresh complete for $pool"      # Change to set the body message of the email
$SmtpClient.Send($MailMessage)
