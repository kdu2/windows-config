# Student Labs Record Logon/Logoff

# Records basic user and computer data to a log file. 
# This script is focussed on collecting data for tracking login/logouts but can 
# be used generically with the activity argument being the name of any event you wish to track.
# if the 2nd argument is 'test', will write to standard output and local home folder, 
# if anything else (including blank), will write to log file

# accepted parameters should be either "logon" or "logoff"
# additional parameter available for testing with local log file
param([string]$activity,[bool]$test=$false,[string]$lab)

# skip if using a admin/test account
if ($env:username -match "pattern") { exit }

# date formatting
$activity_datetime = Get-Date -Format "MM/dd/yyyy hh:mm:ss tt"

# computer name
$computer_name = $env:computername

# operating system info
$os_name = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ProductName).ProductName
switch -Wildcard ($os_name) {
    "Windows 7*" { $os_version = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentVersion).CurrentVersion }
    "Windows 10*" { $os_version = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseId).ReleaseId }
    "Windows Embedded*" { $os_version = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name CurrentVersion).CurrentVersion }
    default { $os_version = "unknown" }
}

# network info
#$nic = Get-WmiObject -Class win32_networkadapterconfiguration -Filter "DHCPEnabled='True'" | where { $_.IPAddress -ne $null }
#$mac_address = $nic.MACAddress
#$ip_address = $nic.IPAddress[0]
$local_connection = Test-Connection -Count 1 -ComputerName $computer_name
$ip_address = $local_connection.IPV4Address
$mac_address = (Get-WmiObject -Class win32_networkadapterconfiguration | where { $_.IPAddress -contains $ip_address }).MACAddress

# hardware info
$processor_info = (Get-WmiObject -Class win32_processor).name
#$processor_type = (Get-WmiObject -Class win32_processor).caption

# user info
$username = $env:username
$userinfo = ([ADSISEARCHER]"samaccountname=$($username)").Findone()
# -replace throws away everything except the value following CN= (the 1st token)
$usergroups = $userinfo.Properties.memberof -replace '^CN=([^,]+).+$','$1'

# set lab prefix
if (!$test) { $lab = $computer_name.Substring(0,11) }
$labs = Import-Csv "\\server\share\folder\labs.csv" | where { $_.prefix -eq $lab } | select prefix,area,group
# if no matches found, set to unknown
if ($labs.area -eq "") {
    $area = "UNKNOWN"
} else {
    $area = $labs.area
}
# set group membership status
if ($usergroups -contains $labs.group) {
    $member = "member"
} else {
    $member = "non-member"
}

# share info
$drive_share = "U:\$username"

# build line to write to log file
$log_entry = "`"$area`",`"$username`",`"$member`",`"$activity`",`"$activity_datetime`",`"$computer_name`",`"$os_name`",`"$os_version`",`"$processor_info`",`"$drive_share`",`"$ip_address`",`"$mac_address`""

# output data ----------------------------------------------
if (!$test) {
    $log_path = "\\server\share\folder"
} else {
    $log_path = "C:\logs"
    if (!(Test-Path "C:\logs")) { New-Item -ItemType Directory -Path "C:\logs" | Out-Null }
}

# log file name
# [area] - [YYYYMMDD].log
$log_date = Get-Date -Format "yyyyMMdd"
$log_filename = "$area - $log_date.log"

# create log file with the header if it doesn't already exist
if (!(Test-Path $log_path/$log_filename)) {
    $log_header = "`"area`",`"username`",`"member`",`"activity`",`"activity_datetime`",`"computer_name`",`"os`",`"os_version`",`"processor_info`",`"drive_share`",`"ip_address`",`"mac_address`""
    Write-Output $log_header | Out-File -Append $log_path\$log_filename
}

# write to file
Write-Output $log_entry | Out-File -Append $log_path\$log_filename
if ($test) { Write-Host $log_entry }
