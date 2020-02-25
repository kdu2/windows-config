# Uninstall Insight if client is detected

function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "C:\logs\insight.log"
}

# get client name
$clientname = Get-ItemPropertyValue -path 'HKCU:\Volatile Environment' -Name ViewClient_Machine_Name

# get computer name
$computername = $env:computername

# get username
$username = $env:USERNAME

# set time and date format
$date = Get-Date -Format "MM-dd-yyyy"
$time = Get-Date -Format "hh:mm:sstt"

# create the directory if it doesn't exist
if (!(Test-Path C:\logs)) { New-Item -ItemType Directory -Path C:\logs }

# begin log
log $(Get-Date)

# record the zero client name and username
log "zero client name is $clientname"
log "username is $username"

# set file path
$filepath = "\\server\share\scripts"

# uninstall Insight client
if (Test-Path "C:\Program Files (x86)\Faronics\Insight\student.exe") {
    Start-Process -FilePath msiexec -ArgumentList "/x $filepath\Student_v8.2379.msi /qn"
    reg delete hklm\software\wow6432node\Insight /f
    Write-Output "$date $time - $clientname | $computername | $username" | Out-File -Append "C:\logs\$clientname`_$computername`_$username`_$date.txt"
} else {
    log "failed to find Insight client"
}
