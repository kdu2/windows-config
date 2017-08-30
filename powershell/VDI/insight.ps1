# Select Insight channel based on client name

function log ([string]$entry) {
    Write-Output $entry | Out-File -Append "C:\logs\insight.log"
}

# get client name from environment variable after login
$clientname = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_Machine_Name
$pool = Get-ItemPropertyValue -Path 'HKCU:\Volatile Environment' -Name ViewClient_Launch_ID

# get computer name
$computername = $env:computername

# get username
$username = $env:USERNAME

# set time and date format
$date = Get-Date -Format "MM-dd-yyyy"
$time = Get-Date -Format "hh:mm:sstt"

# create the director if it doesn't exist
if (!(Test-Path C:\logs)) { New-Item -ItemType Directory -Path C:\logs }

# begin log
log $(Get-Date)

# record the zero client name and username
log "zero client name is $clientname"
log "username is $username"

# extract classroom number from clientname
# assumes format of [single letter campus][3 digit building][3 digit room]-[1 to 3 digit station number][single letter device type]
# e.g. A001101-01Z
# grabs characters 2 through 7 for the building and room number
$classroom = $clientname.Substring(1,6)

# set file path
$filepath = "\\server\share\scripts"

# import classroom info from CSV file
# the CSV file has 3 fields listing the classrooms that are using Insight, the channel for that room, and if Insight is enabled for that room
$insightclassroom = Import-Csv "$filepath\insightclassrooms.csv" | Where-Object {$classroom -eq $_.room} | select room,channel,enabled

# list of faculty with writeable volume
$facultyprofiles = Get-Content "$filepath\facultyprofiles.txt"

# valid pools
$pools = Get-Content "$filepath\insightpools.txt"

# initialize default channel value
$channel = "0"

# check if classroom is valid
# install Insight client and configure with corresponding classroom channel or write error to log
if (($insightclassroom.room -eq $classroom) -and ($insightclassroom.enabled -eq 'Y') -and ($facultyprofiles -notcontains $username) -and ($pools -contains $pool))
{
    $channel = $insightclassroom.channel
    log "selecting classroom channel $channel"
    Start-Process -FilePath msiexec -ArgumentList "/i $filepath\Student.msi /qn ADVANCEDOPTIONS=1 CHANNEL=$channel STEALTHMODE=1 LCS=10.0.1.100" # change IP as needed
    Write-Output "$date $time - $clientname | $computername | $username" | Out-File -Append "C:\logs\$clientname`_$computername`_$username`_$date.txt"
} else {
    log "failed to find classroom channel for $classroom"
}
