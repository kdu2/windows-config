# Select Insight channel based on client name

# get client name from environment variable after login
$clientname = (Get-ItemProperty -path 'HKCU:\Volatile Environment' -name ViewClient_Machine_Name).ViewClient_Machine_Name

# get computer name
$computername = $env:computername

# get username
$username = $env:USERNAME

# set time and date format
$date = Get-Date -Format "MM-dd-yyyy"
$time = Get-Date -Format "hh:mm:sstt"

# create the director if it doesn't exist
if (!(Test-Path C:\logs))
{
    mkdir C:\logs
}

# begin log
$currentdate = Get-Date
$logpath = "C:\logs\insight.log"
Write-Output "$currentdate" | Out-File -Append $logpath

# record the zero client name and username
Write-Output "zero client name is $clientname" | Out-File -Append $logpath
Write-Output "username is $username" | Out-File -Append $logpath

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

# invalid pools
$invalidpools = "PL1","PL2"

# get current pool
$pool = $computername.Substring(4,3)

# initialize default channel value
$channel = "0"

# check if classroom is valid
# install Insight client and configure with corresponding classroom channel or write error to log
if (($insightclassroom.room -eq $classroom) -and ($insightclassroom.enabled -eq 'Y') -and ($facultyprofiles -notcontains $username) -and ($invalidpools -notcontains $pool))
{
    $channel = $insightclassroom.channel
    Write-Output "selecting classroom channel $channel" | Out-File -Append $logpath
    Start-Process -FilePath msiexec -ArgumentList "/i $filepath\Student.msi /qn ADVANCEDOPTIONS=1 CHANNEL=$channel STEALTHMODE=1 LCS=10.0.1.100" # change IP as needed
    Write-Output "$date $time - $clientname | $computername | $username" | Out-File -Append "C:\logs\$clientname`_$computername`_$username`_$date.txt"
} else {
    Write-Output ("failed to find classroom channel for " + $classroom) | Out-File -Append $logpath
}