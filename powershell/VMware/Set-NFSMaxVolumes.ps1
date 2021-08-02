param([string]$vcenter)

Import-Module vmware.vimautomation.core

Connect-VIServer -Server $vcenter -Credential (Get-Credential)

Get-VMHost | foreach { Get-AdvancedSetting -Entity $_.name -Name NFS.MaxVolumes | Set-AdvancedSetting -Value 32 -Confirm:$false }
