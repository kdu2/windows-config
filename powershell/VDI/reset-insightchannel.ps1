# Reset Insight channel on logoff

function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "C:\logs\insight\insight-reset.log"
}

if (!(Test-Path C:\logs\insight)) { New-Item -ItemType Directory -Path C:\logs\insight }

$process = Get-Process -Name "student"
if ($process -ne $null) { $process | Stop-Process -Force }
Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Insight" -Name "Channel" -Type "DWORD" -Value "1000" -Force
$channel = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\WOW6432Node\Insight" -Name Channel
log "$(Get-Date)`nChannel reset to $channel`n"
