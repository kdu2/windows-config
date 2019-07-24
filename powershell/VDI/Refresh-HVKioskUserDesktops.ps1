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

$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "SMTP_HOST"                    # Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "SENDER_EMAIL"      # Change to email address you want emails to be coming from
$MailMessage.To.add("RECIPIENT_EMAIL")     # Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Refresh complete for $username in $pool"   # Change to set your email subject
$MailMessage.Body = "Refresh complete for $username in $pool"      # Change to set the body message of the email
$SmtpClient.Send($MailMessage)
