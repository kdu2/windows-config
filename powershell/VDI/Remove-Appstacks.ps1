# remove app stacks that did not detach correctly after logoff

param([string]$pool)

Import-Module VMware.VimAutomation.Core

Connect-VIServer -Server vcenter.domain

switch ($pool) {
	"pool1" {
		$max = 200
		$prefix = "prefix1"
	}
	"pool2" {
		$max = 100
		$prefix = "prefix2"
	}
	default {
		exit 1
	}
}

for ($i = 1; $i -le $max; $i++) {
	#$linkedclone = "$prefix" + $i.ToString() + "V"
	$linkedclones = Get-VM -Name "$prefix*"
	foreach ($linkedclone in $linkedclones) {
		$disks = Get-HardDisk -VM $linkedclone
    	foreach ($disk in $disks) {
			$diskname = $disk.Filename
			$disksize = $disk.CapacityGB
			# replace datastore path with your own if not using default name from app volumes and default disk size
			if (($diskname -like "*cloudvolumes/apps/*") -and ($disksize -eq 20)) {
				Write-Output "VM $linkedclone - removing $diskname" | Out-File -Append "appstack-removal-$pool.log"
				Remove-HardDisk $disk -Confirm:$false
			}
    	}
	}
}

$SmtpClient = New-Object system.net.mail.smtpClient
$SmtpClient.host = "smtp.domain.com"   #Change to a SMTP server in your environment
$MailMessage = New-Object system.net.mail.mailmessage
$MailMessage.from = "vdiDesktopSupport@domain.com"   #Change to email address you want emails to be coming from
$MailMessage.To.add("vdiDesktopSupport@domain.com")    #Change to email address you want send to
$MailMessage.IsBodyHtml = 1
$MailMessage.Subject = "Remove AppStacks from $pool"    #Change to set your email subject
$MailMessage.Body = "Removal of AppStacks from $pool has Started, please verify all AppStack datastores do not have any remaining VMs"    #Change to set the body message of the email
$SmtpClient.Send($MailMessage)
