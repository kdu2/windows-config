param(
    $pool = "POOL",
    $domain = "domainfqdn"
    $username = "user"
)

Add-PSSnapin "vmware.view.broker"
$desktops = Get-RemoteSession -username "$domain\$username" -pool_id $pool

foreach ($desktop in $desktops) {
    Get-DesktopVM -pool_id $pool -Name $desktop.dnsname.trimend(".$domain") | Send-LinkedCloneRefresh -schedule ((Get-Date).AddMinutes(1)) -ForceLogoff $true -stopOnError $false
}
 
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "SMTP_HOST"                    # Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "SENDER_EMAIL"      # Change to email address you want emails to be coming from
$MailMessage.To.add("RECIPIENT_EMAIL")     # Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Refresh complete for $username in $pool"   # Change to set your email subject
$MailMessage.Body = "Refresh complete for $usernamem in $pool"      # Change to set the body message of the email
$SmtpClient.Send($MailMessage)
