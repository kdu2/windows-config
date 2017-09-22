param($ConnectionServer)

Add-PSSnapin vmware.view.broker
Connect-VIServer $ConnectionServer
Get-Pool -pool_id $pool | Get-DesktopVM | Send-LinkedCloneRefresh -schedule ((Get-Date).AddMinutes(1)) -ForceLogoff $true
 
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "smtp.domain.com"   #Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "vdiDesktopSupport@domain.com"   #Change to email address you want emails to be coming from
$MailMessage.To.add("vdiDesktopSupport@domain.com")    #Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Refresh complete for $pool"    #Change to set your email subject
$MailMessage.Body = "Refresh complete for $pool"    #Change to set the body message of the email
$SmtpClient.Send($MailMessage)
