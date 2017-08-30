﻿# script to log specific client and desktop being used by a user
# this makes it easier to refer to where someone is sitting when troubleshooting

# get client name from environment variable after login
$clientname = (Get-ItemProperty -path 'HKCU:\Volatile Environment' -name ViewClient_Machine_Name).ViewClient_Machine_Name

# get computer name
$computername = $env:computername

# get username
$username = $env:USERNAME

# set date and time format
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "hh:mm:sstt"

# extract desktop pool from environment variable after login
$pool = (Get-ItemProperty -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID).ViewClient_Launch_ID

# list of valid pools
$pools = Get-Content "\\server\share\pools.txt"

# log save path
$logfile = "\\server\share\logs\clients-$date.log"

# construct log entry based on client and computer name length. adds whitespace to line up evenly per line
While ($clientname.Length -lt 14) { $clientname = "$clientname " }
While ($computername.Length -lt 14) { $computername = "$computername " }
$logentry = "$time - $clientname | $computername | $username"

# check if classroom is valid
if ($pools -contains $pool) {
    # create the daily log file if it doesn't exist
    if (!(Test-Path $logfile)) {
        Write-Output $date | Out-File -Append $logfile
    }
    # record zero client name, computer name and username
    Write-Output $logentry | Out-File -Append $logfile
}
