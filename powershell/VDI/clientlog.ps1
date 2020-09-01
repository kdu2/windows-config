# script to log specific client and desktop being used by a user
# this makes it easier to refer to where someone is sitting when troubleshooting

# get client name from environment variable after login
$clientname = (Get-ItemProperty -path 'HKCU:\Volatile Environment' -name ViewClient_Machine_Name).ViewClient_Machine_Name
$clientIP = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_IP_Address
$desktopIP = (Test-Connection -Count 1 -ComputerName $env:computername).IPV4Address

# get computer name
$computername = $env:computername

# get username
$username = $env:USERNAME

# set date and time format
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "hh:mm:sstt"

# extract desktop pool from environment variable after login
$pool = (Get-ItemProperty -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID).ViewClient_Launch_ID

# log save path
$logfile = "\\server\share\logs\clients-$date.log"

# construct log entry
$logentry = "`"$time`",`"$clientname`",`"$clientIP`",`"$pool`",`"$computername`",`"$desktopIP`",`"$username`""

# create log file
if (!(Test-Path $logfile)) {
    Write-Output "`"time`",`"clientname`",`"client IP`",`"desktop pool`",`"computername`",`"desktop IP`",`"username`"" | Out-File -Append $logfile -Encoding Ascii
}
# write to log
Write-Output $logentry | Out-File -Append $logfile -Encoding Ascii
