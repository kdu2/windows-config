param($ConnectionServer,$ParentVMPath,$ParentVMSnapshotPath,$delay)

Add-PSSnapin vmware.view.broker
Connect-VIServer $ConnectionServer
Get-Pool -pool_id $pool | Send-LinkedCloneRecompose -schedule ((Get-Date).AddMinutes($delay)) -parentVMPath $ParentVMPath  -parentSnapshotPath $ParentVMSnapshotPath -ForceLogoff $true -stopOnError $false
 
$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "smtp.domain.com"   #Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "vdiDesktopSupport@domain.com"   #Change to email address you want emails to be coming from
$MailMessage.To.add("vdiDesktopSupport@domain.com")    #Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Recompose complete for $pool"    #Change to set your email subject
$MailMessage.Body = "Recompose complete for $pool"    #Change to set the body message of the email
$SmtpClient.Send($MailMessage)
