# Reset Insight channel on logoff

$process = Get-Process | where { $_.name -eq "student" }
if ($process -ne $null) { Stop-Process -Name "student" -Force }
Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Insight" -Name "Channel" -Type "DWORD" -Value "1000" -Force
